# BSD 3-Clause License
#
# Copyright (c) 2022, Denis Bourgeois
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require "openstudio"
require "json"
require "csv"

module Outilities
  extend OSlg

  TOL = 0.01
  TOL2 = TOL * TOL

  # This first set of utilities helps distinguishing surfaces enclosing spaces
  # that are directly vs indirectly CONDITIONED, vs SEMI-HEATED. In many
  # cases, it is desirable to set aside surfaces in UNCONDITIONED or UNENCLOSED
  # spaces. The solution here relies as much as possible on space conditioning
  # categories found in standards like ASHRAE 90.1 and energy codes like the
  # Canadian NECB editions. Both documents share many similarities, regardless
  # of nomenclature. There are however noticeable differences between approaches
  # on how a space is tagged as falling into one of the aforementioned
  # categories. First, an overview of 90.1 requirements (with some minor edits
  # for brevity + added emphasis):
  #
  # www.pnnl.gov/main/publications/external/technical_reports/PNNL-26917.pdf
  #
  #   3.2.1. General Information - SPACE CONDITIONING CATEGORY
  #
  #     - CONDITIONED space: an ENCLOSED space that has a heating and/or
  #       cooling system of sufficient size to maintain temperatures suitable
  #       for HUMAN COMFORT:
  #         - COOLED: cooled by a system >= 10 W/m2
  #         - HEATED: heated by a system e.g., >= 50 W/m2 in Climate Zone CZ-7
  #         - INDIRECTLY: heated or cooled via adjacent space(s) provided:
  #             - UA of adjacent surfaces > UA of other surfaces
  #                 or
  #             - intentional air transfer from HEATED/COOLED space > 3 ACH
  #
  #               ... includes plenums, atria, etc.
  #
  #     - SEMI-HEATED space: an ENCLOSED space that has a heating system
  #       >= 10 W/m2, yet NOT a CONDITIONED space (see above).
  #
  #     - UNCONDITIONED space: an ENCLOSED space that is NOT a conditioned
  #       space or a SEMI-HEATED space (see above).
  #
  #       NOTE: Crawlspaces, attics, and parking garages with natural or
  #       mechanical ventilation are considered UNENCLOSED spaces.
  #
  #       2.3.3 Modeling Requirements: surfaces adjacent to UNENCLOSED spaces
  #       shall be treated as exterior surfaces. All other UNENCLOSED surfaces
  #       are to be modeled as is in both proposed and baseline models. For
  #       instance, modeled fenestration in UNENCLOSED spaces would not be
  #       factored in WWR calculations.
  #
  #
  # Related NECB definitions and concepts, starting with CONDITIONED space:
  #
  # "[...] the temperature of which is controlled to limit variation in
  # response to the exterior ambient temperature by the provision, either
  # DIRECTLY or INDIRECTLY, of heating or cooling [...]". Although criteria
  # differ (e.g., not sizing-based), the general idea is sufficiently similar
  # to ASHRAE 90.1 (e.g., heating and/or cooling based, no distinction for
  # INDIRECTLY conditioned spaces like plenums).
  #
  # SEMI-HEATED spaces are also a defined NECB term, but again the distinction
  # is based on desired/intended design space setpoint temperatures - not
  # system sizing criteria. No further treatment is implemented here to
  # distinguish SEMI-HEATED from CONDITIONED spaces.
  #
  # The single NECB criterion distinguishing UNCONDITIONED ENCLOSED spaces
  # (such as vestibules) from UNENCLOSED spaces (such as attics) remains the
  # intention to ventilate - or rather to what degree. Regardless, the methods
  # here are designed to process both classifications in the same way, namely by
  # focusing on adjacent surfaces to CONDITIONED (or SEMI-HEATED) spaces as part
  # of the building envelope.

  # In light of the above, the methods here are designed to handle envelope
  # surfaces without a priori knowledge of explicit system sizing choices or
  # access to iterative autosizing processes. As discussed in the following,
  # the methods are developed to rely on zoning info and/or "intended"
  # temperature setpoints to determine which surfaces to process.
  #
  # For an OpenStudio model (OSM) in an incomplete or preliminary state, e.g.
  # holding fully-formed ENCLOSED spaces without thermal zoning information or
  # setpoint temperatures [early design stage assessments of form, porosity or
  # envelope]), all OSM spaces will be considered CONDITIONED, presuming
  # setpoints of ~21°C (heating) and ~24°C (cooling).
  #
  # If any valid space/zone-specific temperature setpoints are found in the OSM,
  # the following methods will seek to tag outdoor-facing opaque surfaces with
  # their parent space/zone's explicit heating (max) and/or cooling (min)
  # setpoints. In such cases, spaces/zones without valid heating or cooling
  # setpoints are either considered as UNCONDITIONED or UNENCLOSED spaces
  # (like attics), or INDIRECTLY CONDITIONED spaces (like plenums), see
  # "plenum?" method.

  ##
  # Return min & max values of a schedule (ruleset).
  #
  # @param sched [OpenStudio::Model::ScheduleRuleset] schedule (ruleset)
  #
  # @return [Hash] min: (Float), max (Float):
  # @return [Hash] min: nil, max: nil (if invalid input)
  def scheduleRulesetMinMax(sched)
    # Largely inspired from David Goldwasser's
    # "schedule_ruleset_annual_min_max_value":
    #
    # github.com/NREL/openstudio-standards/blob/
    # 99cf713750661fe7d2082739f251269c2dfd9140/lib/openstudio-standards/
    # standards/Standards.ScheduleRuleset.rb#L124
    res = { min: nil, max: nil }
    cl = OpenStudio::Model::ScheduleRuleset
    return res unless sched && sched.is_a?(cl)

    profiles = []
    profiles << sched.defaultDaySchedule
    rules = sched.scheduleRules
    rules.each { |rule| profiles << rule.daySchedule }

    min = nil
    max = nil

    profiles.each do |profile|
      profile.values.each do |value|
        next unless value.is_a?(Numeric)

        if min
          min = value if min > value
        else
          min = value
        end

        if max
          max = value if max < value
        else
          max = value
        end
      end
    end

    res[:min] = min
    res[:max] = max
    res
  end

  ##
  # Return min & max values of a schedule (constant).
  #
  # @param sched [OpenStudio::Model::ScheduleConstant] schedule (constant)
  #
  # @return [Hash] min: (Float), max: (Float)
  # @return [Hash] min: nil, max: nil (if invalid input)
  def scheduleConstantMinMax(sched)
    # Largely inspired from David Goldwasser's
    # "schedule_constant_annual_min_max_value":
    #
    # github.com/NREL/openstudio-standards/blob/
    # 99cf713750661fe7d2082739f251269c2dfd9140/lib/openstudio-standards/
    # standards/Standards.ScheduleConstant.rb#L21
    res = { min: nil, max: nil }
    cl = OpenStudio::Model::ScheduleConstant
    return res unless sched && sched.is_a?(cl)

    min = nil
    min = sched.value if sched.value.is_a?(Numeric)
    max = min

    res[:min] = min
    res[:max] = max
    res
  end

  ##
  # Return min & max values of a schedule (compact).
  #
  # @param sched [OpenStudio::Model::ScheduleCompact] schedule (compact)
  #
  # @return [Hash] min: (Float), max: (Float)
  # @return [Hash] min: nil, max: nil (if invalid input)
  def scheduleCompactMinMax(sched)
    # Largely inspired from Andrew Parker's
    # "schedule_compact_annual_min_max_value":
    #
    # github.com/NREL/openstudio-standards/blob/
    # 99cf713750661fe7d2082739f251269c2dfd9140/lib/openstudio-standards/
    # standards/Standards.ScheduleCompact.rb#L8
    res = { min: nil, max: nil }
    cl = OpenStudio::Model::ScheduleCompact
    return res unless sched && sched.is_a?(cl)

    min = nil
    max = nil

    vals = []
    prev_str = ""

    sched.extensibleGroups.each do |eg|
      if prev_str.include?("until")
        vals << eg.getDouble(0).get unless eg.getDouble(0).empty?
      end

      str = eg.getString(0)
      prev_str = str.get.downcase unless str.empty?
    end

    unless vals.empty?
      min = vals.min if vals.min.is_a?(Numeric)
      max = vals.max if vals.min.is_a?(Numeric)
    end

    res[:min] = min
    res[:max] = max
    res
  end

  ##
  # Return max zone heating temperature schedule setpoint [°C] and whether
  # zone has active dual setpoint thermostat.
  #
  # @param zone [OpenStudio::Model::ThermalZone] a thermal zone
  #
  # @return [Hash] setpoint: (Float), dual: (Bool)
  # @return [Hash] setpoint: nil, dual: false (if invalid input)
  def maxHeatScheduledSetpoint(zone)
    # Largely inspired from Parker & Marrec's "thermal_zone_heated?" procedure.
    # The solution here is a tad more relaxed to encompass SEMI-HEATED zones as
    # per Canadian NECB criteria (basically any space with at least 10 W/m2 of
    # installed heating equipement, i.e. below freezing in Canada).
    #
    # github.com/NREL/openstudio-standards/blob/
    # 58964222d25783e9da4ae292e375fb0d5c902aa5/lib/openstudio-standards/
    # standards/Standards.ThermalZone.rb#L910
    res = { setpoint: nil, dual: false }
    cl = OpenStudio::Model::ThermalZone
    return res unless zone && zone.is_a?(cl)

    # Zone radiant heating? Get schedule from radiant system.
    zone.equipment.each do |equip|
      sched = nil

      unless equip.to_ZoneHVACHighTemperatureRadiant.empty?
        equip = equip.to_ZoneHVACHighTemperatureRadiant.get

        unless equip.heatingSetpointTemperatureSchedule.empty?
          sched = equip.heatingSetpointTemperatureSchedule.get
        end
      end

      unless equip.to_ZoneHVACLowTemperatureRadiantElectric.empty?
        equip = equip.to_ZoneHVACLowTemperatureRadiantElectric.get

        unless equip.heatingSetpointTemperatureSchedule.empty?
          sched = equip.heatingSetpointTemperatureSchedule.get
        end
      end

      unless equip.to_ZoneHVACLowTempRadiantConstFlow.empty?
        equip = equip.to_ZoneHVACLowTempRadiantConstFlow.get
        coil = equip.heatingCoil

        unless coil.to_CoilHeatingLowTempRadiantConstFlow.empty?
          coil = coil.to_CoilHeatingLowTempRadiantConstFlow.get

          unless coil.heatingHighControlTemperatureSchedule.empty?
            sched = c.heatingHighControlTemperatureSchedule.get
          end
        end
      end

      unless equip.to_ZoneHVACLowTempRadiantVarFlow.empty?
        equip = equip.to_ZoneHVACLowTempRadiantVarFlow.get
        coil = equip.heatingCoil

        unless coil.to_CoilHeatingLowTempRadiantVarFlow.empty?
          coil = coil.to_CoilHeatingLowTempRadiantVarFlow.get

          unless coil.heatingControlTemperatureSchedule.empty?
            sched = coil.heatingControlTemperatureSchedule.get
          end
        end
      end

      next unless sched

      unless sched.to_ScheduleRuleset.empty?
        sched = sched.to_ScheduleRuleset.get
        max = scheduleRulesetMinMax(sched)[:max]

        if max
          if res[:setpoint]
            res[:setpoint] = max if max > res[:setpoint]
          else
            res[:setpoint] = max
          end
        end
      end

      unless sched.to_ScheduleConstant.empty?
        sched = sched.to_ScheduleConstant.get
        max = scheduleConstantMinMax(sched)[:max]

        if max
          if res[:setpoint]
            res[:setpoint] = max if max > res[:setpoint]
          else
            res[:setpoint] = max
          end
        end
      end

      unless sched.to_ScheduleCompact.empty?
        sched = sched.to_ScheduleCompact.get
        max = scheduleCompactMinMax(sched)[:max]

        if max
          if res[:setpoint]
            res[:setpoint] = max if max > res[:setpoint]
          else
            res[:setpoint] = max
          end
        end
      end
    end

    return res if res[:setpoint]
    return res if zone.thermostat.empty?
    tstat = zone.thermostat.get

    unless tstat.to_ThermostatSetpointDualSetpoint.empty? &&
           tstat.to_ZoneControlThermostatStagedDualSetpoint.empty?
      res[:dual] = true

      unless tstat.to_ThermostatSetpointDualSetpoint.empty?
        tstat = tstat.to_ThermostatSetpointDualSetpoint.get
      else
        tstat = tstat.to_ZoneControlThermostatStagedDualSetpoint.get
      end

      unless tstat.heatingSetpointTemperatureSchedule.empty?
        sched = tstat.heatingSetpointTemperatureSchedule.get

        unless sched.to_ScheduleRuleset.empty?
          sched = sched.to_ScheduleRuleset.get
          max = scheduleRulesetMinMax(sched)[:max]

          if max
            if res[:setpoint]
              res[:setpoint] = max if max > res[:setpoint]
            else
              res[:setpoint] = max
            end
          end

          dd = sched.winterDesignDaySchedule

          unless dd.values.empty?
            if res[:setpoint]
              res[:setpoint] = dd.values.max if dd.values.max > res[:setpoint]
            else
              res[:setpoint] = dd.values.max
            end
          end
        end

        unless sched.to_ScheduleConstant.empty?
          sched = sched.to_ScheduleConstant.get
          max = scheduleConstantMinMax(sched)[:max]

          if max
            if res[:setpoint]
              res[:setpoint] = max if max > res[:setpoint]
            else
              res[:setpoint] = max
            end
          end
        end

        unless sched.to_ScheduleCompact.empty?
          sched = sched.to_ScheduleCompact.get
          max = scheduleCompactMinMax(sched)[:max]

          if max
            if res[:setpoint]
              res[:setpoint] = max if max > res[:setpoint]
            else
              res[:setpoint] = max
            end
          end
        end

        unless sched.to_ScheduleYear.empty?
          sched = sched.to_ScheduleYear.get

          sched.getScheduleWeeks.each do |week|
            next if week.winterDesignDaySchedule.empty?
            dd = week.winterDesignDaySchedule.get
            next unless dd.values.empty?

            if res[:setpoint]
              res[:setpoint] = dd.values.max if dd.values.max > res[:setpoint]
            else
              res[:setpoint] = dd.values.max
            end
          end
        end
      end
    end

    res
  end

  ##
  # Validate if model has zones with valid heating temperature setpoints.
  #
  # @param model [OpenStudio::Model::Model] a model
  #
  # @return [Bool] true if valid heating temperature setpoints
  def heatingTemperatureSetpoints?(model)
    return false unless model && model.is_a?(OpenStudio::Model::Model)

    model.getThermalZones.each do |zone|
      max, _ = maxHeatScheduledSetpoint(zone)
      return true if max
    end

    false
  end

  ##
  # Return min zone cooling temperature schedule setpoint [°C] and whether
  # zone has active dual setpoint thermostat.
  #
  # @param zone [OpenStudio::Model::ThermalZone] a thermal zone
  #
  # @return [Hash] setpoint: (Float), dual: (Bool)
  # @return [Hash] setpoint: nil, dual: false (if invalid input)
  def minCoolScheduledSetpoint(zone)
    # Largely inspired from Parker & Marrec's "thermal_zone_cooled?" procedure.
    #
    # github.com/NREL/openstudio-standards/blob/
    # 99cf713750661fe7d2082739f251269c2dfd9140/lib/openstudio-standards/
    # standards/Standards.ThermalZone.rb#L1058
    res = { setpoint: nil, dual: false }
    cl = OpenStudio::Model::ThermalZone
    return res unless zone && zone.is_a?(cl)

    # Zone radiant cooling? Get schedule from radiant system.
    zone.equipment.each do |equip|
      sched = nil

      unless equip.to_ZoneHVACLowTempRadiantConstFlow.empty?
        equip = equip.to_ZoneHVACLowTempRadiantConstFlow.get
        coil = equip.coolingCoil

        unless coil.to_CoilCoolingLowTempRadiantConstFlow.empty?
          coil = coil.to_CoilCoolingLowTempRadiantConstFlow.get

          unless coil.coolingLowControlTemperatureSchedule.empty?
            sched = coil.coolingLowControlTemperatureSchedule.get
          end
        end
      end

      unless equip.to_ZoneHVACLowTempRadiantVarFlow.empty?
        equip = equip.to_ZoneHVACLowTempRadiantVarFlow.get
        coil = equip.coolingCoil

        unless coil.to_CoilCoolingLowTempRadiantVarFlow.empty?
          coil = coil.to_CoilCoolingLowTempRadiantVarFlow.get

          unless coil.coolingControlTemperatureSchedule.empty?
            sched = coil.coolingControlTemperatureSchedule.get
          end
        end
      end

      next unless sched

      unless sched.to_ScheduleRuleset.empty?
        sched = sched.to_ScheduleRuleset.get
        min = scheduleRulesetMinMax(sched)[:min]

        if min
          if res[:setpoint]
            res[:setpoint] = min if min < res[:setpoint]
          else
            res[:setpoint] = min
          end
        end
      end

      unless sched.to_ScheduleConstant.empty?
        sched = sched.to_ScheduleConstant.get
        min = scheduleConstantMinMax(sched)[:min]

        if min
          if res[:setpoint]
            res[:setpoint] = min if min < res[:setpoint]
          else
            res[:setpoint] = min
          end
        end
      end

      unless sched.to_ScheduleCompact.empty?
        sched = sched.to_ScheduleCompact.get
        min = scheduleCompactMinMax(sched)[:min]

        if min
          if res[:setpoint]
            res[:setpoint] = min if min < res[:setpoint]
          else
            res[:setpoint] = min
          end
        end
      end
    end

    return res if res[:setpoint]
    return res if zone.thermostat.empty?
    tstat = zone.thermostat.get

    unless tstat.to_ThermostatSetpointDualSetpoint.empty? &&
           tstat.to_ZoneControlThermostatStagedDualSetpoint.empty?
      dual = true

      unless tstat.to_ThermostatSetpointDualSetpoint.empty?
        tstat = tstat.to_ThermostatSetpointDualSetpoint.get
      else
        tstat = tstat.to_ZoneControlThermostatStagedDualSetpoint.get
      end

      unless tstat.coolingSetpointTemperatureSchedule.empty?
        sched = tstat.coolingSetpointTemperatureSchedule.get

        unless sched.to_ScheduleRuleset.empty?
          sched = sched.to_ScheduleRuleset.get
          min = scheduleRulesetMinMax(sched)[:min]

          if min
            if res[:setpoint]
              res[:setpoint] = min if min < res[:setpoint]
            else
              res[:setpoint] = min
            end
          end

          dd = sched.summerDesignDaySchedule

          unless dd.values.empty?
            if res[:setpoint]
              res[:setpoint] = dd.values.min if dd.values.min < setpoint
            else
              res[:setpoint] = dd.values.min
            end
          end
        end

        unless sched.to_ScheduleConstant.empty?
          sched = sched.to_ScheduleConstant.get
          min = scheduleConstantMinMax(sched)[:min]

          if min
            if res[:setpoint]
              res[:setpoint] = min if min < res[:setpoint]
            else
              res[:setpoint] = min
            end
          end
        end

        unless sched.to_ScheduleCompact.empty?
          sched = sched.to_ScheduleCompact.get
          min = scheduleCompactMinMax(sched)[:min]

          if min
            if res[:setpoint]
              res[:setpoint] = min if min < res[:setpoint]
            else
              res[:setpoint] = min
            end
          end
        end

        unless sched.to_ScheduleYear.empty?
          sched = sched.to_ScheduleYear.get

          sched.getScheduleWeeks.each do |week|
            next if week.summerDesignDaySchedule.empty?
            dd = week.summerDesignDaySchedule.get
            next unless dd.values.empty?

            if res[:setpoint]
              res[:setpoint] = dd.values.min if dd.values.min < res[:setpoint]
            else
              res[:setpoint] = dd.values.min
            end
          end
        end
      end
    end

    res
  end

  ##
  # Validate if model has zones with valid cooling temperature setpoints.
  #
  # @param model [OpenStudio::Model::Model] a model
  #
  # @return [Bool] true if valid cooling temperature setpoints
  def coolingTemperatureSetpoints?(model)
    return false unless model && model.is_a?(OpenStudio::Model::Model)

    model.getThermalZones.each do |zone|
      min, _ = minCoolScheduledSetpoint(zone)
      return true if min
    end

    false
  end

  ##
  # Validate if model has zones with HVAC air loops.
  #
  # @param model [OpenStudio::Model::Model] a model
  #
  # @return [Bool] true if model has one or more HVAC air loops
  def airLoopsHVAC?(model)
    answer = false
    return answer unless model && model.is_a?(OpenStudio::Model::Model)

    model.getThermalZones.each do |zone|
      next if answer
      next if zone.canBePlenum
      answer = true unless zone.airLoopHVACs.empty?
      answer = true if zone.isPlenum
    end

    answer
  end

  ##
  # Validate whether space should be processed as a plenum.
  #
  # @param space [OpenStudio::Model::Space] a space
  # @param loops [Bool] true if model has airLoopHVAC object(s)
  # @param setpoints [Bool] true if model has valid temperature setpoints
  #
  # @return [Bool] true if should be tagged as plenum.
  def plenum?(space, loops, setpoints)
    # Largely inspired from NREL's "space_plenum?" procedure.
    #
    # github.com/NREL/openstudio-standards/blob/
    # 58964222d25783e9da4ae292e375fb0d5c902aa5/lib/openstudio-standards/
    # standards/Standards.Space.rb#L1384

    # For a fully-developed OpenStudio model (complete with HVAC air loops),
    # space tagged as plenum if zone "isPlenum" (case A).
    #
    # In absence of HVAC air loops, 2x other cases trigger a plenum tag:
    #   case B. space excluded from building's total floor area, yet zone holds
    #           an "inactive" thermostat (i.e., can't extract valid setpoints);
    #           ... or
    #   case C. spacetype is "plenum".
    cl = OpenStudio::Model::Space
    return false unless space && space.is_a?(cl)
    return false unless loops == true || loops == false
    return false unless setpoints == true || setpoints == false

    unless space.thermalZone.empty?
      zone = space.thermalZone.get
      return zone.isPlenum if loops                                     # case A

      if setpoints
        heating, dual1 = maxHeatScheduledSetpoint(zone)
        cooling, dual2 = minCoolScheduledSetpoint(zone)
        return false if heating || cooling          # directly conditioned space

        unless space.partofTotalFloorArea
          return true if dual1 || dual2                                 # case B
        else
          return false
        end
      end
    end

    unless space.spaceType.empty?                                       # case C
      type = space.spaceType.get
      return true if type.nameString.downcase == "plenum"

      unless type.standardsSpaceType.empty?
        type = type.standardsSpaceType.get
        return true if type.downcase == "plenum"
      end
    end

    false
  end

  ##
  # Generate an HVAC availability schedule.
  #
  # @param model [OpenStudio::Model::Model] a model
  # @param avl [String] seasonal availability option (default "ON")
  #
  # @return [OpenStudio::Model::Schedule] HVAC avail sched
  # @return [nil] if in valid input
  def availabilitySchedule(model, avl = "")
    return nil unless model && model.is_a?(OpenStudio::Model::Model)

    # First, fetch availability ScheduleTypeLimits object - or create one.
    limits = nil

    model.getScheduleTypeLimitss.each do |l|
      break if limits
      next if l.lowerLimitValue.empty?
      next if l.upperLimitValue.empty?
      next if l.numericType.empty?
      next unless l.lowerLimitValue.get.to_i == 0
      next unless l.upperLimitValue.get.to_i == 1
      next unless l.numericType.get.downcase == "discrete"
      next unless l.unitType.downcase == "availability"
      next unless l.nameString.downcase == "hvac operation scheduletypelimits"
      limits = l
    end

    unless limits
      limits = OpenStudio::Model::ScheduleTypeLimits.new(model)
      limits.setName("HVAC Operation ScheduleTypeLimits")
      limits.setLowerLimitValue(0)
      limits.setUpperLimitValue(1)
      limits.setNumericType("Discrete")
      limits.setUnitType("Availability")
    end

    time = OpenStudio::Time.new(0,24)
    secs = time.totalSeconds

    on = OpenStudio::Model::ScheduleDay.new(model, 1)
    off = OpenStudio::Model::ScheduleDay.new(model, 0)

    # Seasonal availability start/end dates.
    year = model.yearDescription
    return nil if year.empty?
    year = year.get
    may01 = year.makeDate(OpenStudio::MonthOfYear.new("May"),  1)
    oct31 = year.makeDate(OpenStudio::MonthOfYear.new("Oct"), 31)

    case avl.downcase
    when "winter"             # available from November 1 to April 30 (6 months)
      val = 1
      sch = off
      nom = "WINTER Availability SchedRuleset"
      dft = "WINTER Availability dftDaySched"
      tag = "May-Oct WINTER Availability SchedRule"
      day = "May-Oct WINTER SchedRule Day"
    when "summer"                # available from May 1 to October 31 (6 months)
      val = 0
      sch = on
      nom = "SUMMER Availability SchedRuleset"
      dft = "SUMMER Availability dftDaySched"
      tag = "May-Oct SUMMER Availability SchedRule"
      day = "May-Oct SUMMER SchedRule Day"
    when "off"                                                 # never available
      val = 0
      sch = on
      nom = "OFF Availability SchedRuleset"
      dft = "OFF Availability dftDaySched"
      tag = ""
      day = ""
    else                                                      # always available
      val = 1
      sch = on
      nom = "ON Availability SchedRuleset"
      dft = "ON Availability dftDaySched"
      tag = ""
      day = ""
    end

    # Fetch existing schedule.
    ok = true
    schedule = model.getScheduleByName(nom)

    unless schedule.empty?
      schedule = schedule.get.to_ScheduleRuleset

      unless schedule.empty?
        schedule = schedule.get
        default = schedule.defaultDaySchedule
        ok = ok && default.nameString == dft
        ok = ok && default.times.size == 1
        ok = ok && default.values.size == 1
        ok = ok && default.times.first == time
        ok = ok && default.values.first == val
        rules = schedule.scheduleRules
        ok = ok && (rules.size == 0 || rules.size == 1)

        if rules.size == 1
          rule = rules.first
          ok = ok && rule.nameString == tag
          ok = ok && !rule.startDate.empty?
          ok = ok && !rule.endDate.empty?
          ok = ok && rule.startDate.get == may01
          ok = ok && rule.endDate.get == oct31
          ok = ok && rule.applyAllDays

          d = rule.daySchedule
          ok = ok && d.nameString == day
          ok = ok && d.times.size == 1
          ok = ok && d.values.size == 1
          ok = ok && d.times.first.totalSeconds == secs
          ok = ok && d.values.first.to_i != val
        end

        return schedule if ok
      end
    end

    schedule = OpenStudio::Model::ScheduleRuleset.new(model)
    return nil unless schedule.setScheduleTypeLimits(limits)
    schedule.setName(nom)
    return nil unless schedule.defaultDaySchedule.addValue(time, val)
    schedule.defaultDaySchedule.setName(dft)

    unless tag.empty?
      rule = OpenStudio::Model::ScheduleRule.new(schedule, sch)
      rule.setName(tag)
      return nil unless rule.setStartDate(may01)
      return nil unless rule.setEndDate(oct31)
      return nil unless rule.setApplyAllDays(true)
      rule.daySchedule.setName(day)
    end

    schedule
  end

  ##
  # Return OpenStudio site/space transformation & rotation angle [0,2PI) rads.
  #
  # @param model [OpenStudio::Model::Model] a model
  # @param group [OpenStudio::Model::PlanarSurfaceGroup] a group
  #
  # @return [Hash] t: (OpenStudio::Transformation), r: Float
  # @return [Hash] t: nil, r: nil (if invalid input)
  def transforms(model, group)
    cl1 = OpenStudio::Model::Model
    cl2 = OpenStudio::Model::Space
    cl3 = OpenStudio::Model::ShadingSurfaceGroup

    return nil, nil unless model && model.is_a?(cl1)
    return nil, nil unless group && group.is_a?(cl2) || group.is_a?(cl3)

    t = group.siteTransformation
    r = group.directionofRelativeNorth + model.getBuilding.northAxis
    return t, r
  end

  ##
  # Validate if default construction set holds a base ground construction.
  #
  # @param set [OpenStudio::Model::DefaultConstructionSet] a default set
  # @param base [OpensStudio::Model::ConstructionBase] a construction base
  # @param type [String] a surface type
  # @param ground [Bool] true if ground-facing surface
  # @param exterior [Bool] true if exterior-facing surface
  #
  # @return [Bool] true if default construction set holds construction
  def holdsConstruction?(set, base, ground, exterior, type)
    cl = OpenStudio::Model::DefaultConstructionSet
    return false unless set && set.is_a?(cl)
    return false unless base && base.is_a?(OpenStudio::Model::ConstructionBase)
    return false unless ground == true || ground == false
    return false unless exterior == true || exterior == false
    return false unless type
    typ = type.downcase
    return false unless typ == "floor" || typ == "wall" || typ == "roofceiling"

    constructions = nil

    if ground
      unless set.defaultGroundContactSurfaceConstructions.empty?
        constructions = set.defaultGroundContactSurfaceConstructions.get
      end
    elsif exterior
      unless set.defaultExteriorSurfaceConstructions.empty?
        constructions = set.defaultExteriorSurfaceConstructions.get
      end
    else
      unless set.defaultInteriorSurfaceConstructions.empty?
        constructions = set.defaultInteriorSurfaceConstructions.get
      end
    end

    return false unless constructions

    case typ
    when "roofceiling"
      unless constructions.roofCeilingConstruction.empty?
        construction = constructions.roofCeilingConstruction.get
        return true if construction == base
      end
    when "floor"
      unless constructions.floorConstruction.empty?
        construction = constructions.floorConstruction.get
        return true if construction == base
      end
    else
      unless constructions.wallConstruction.empty?
        construction = constructions.wallConstruction.get
        return true if construction == base
      end
    end

    false
  end

  ##
  # Return a surface's default construction set.
  #
  # @param model [OpenStudio::Model::Model] a model
  # @param s [OpenStudio::Model::Surface] a surface
  #
  # @return [OpenStudio::Model::DefaultConstructionSet] default set
  # @return [nil] if invalid input
  def defaultConstructionSet(model, s)
    return nil unless model && model.is_a?(OpenStudio::Model::Model)
    return nil unless s && s.is_a?(OpenStudio::Model::Surface)
    return nil unless s.isConstructionDefaulted

    ground = false
    ground = true if s.isGroundSurface
    exterior = false
    exterior = true if s.outsideBoundaryCondition.downcase == "outdoors"
    return nil if s.construction.empty?
    base = s.construction.get
    return nil if s.space.empty?
    space = s.space.get
    type = s.surfaceType

    unless space.defaultConstructionSet.empty?
      set = space.defaultConstructionSet.get
      return set if holdsConstruction?(set, base, ground, exterior, type)
    end

    unless space.spaceType.empty?
      spacetype = space.spaceType.get

      unless spacetype.defaultConstructionSet.empty?
        set = spacetype.defaultConstructionSet.get
        return set if holdsConstruction?(set, base, ground, exterior, type)
      end
    end

    unless space.buildingStory.empty?
      story = space.buildingStory.get

      unless story.defaultConstructionSet.empty?
        set = story.defaultConstructionSet.get
        return set if holdsConstruction?(set, base, ground, exterior, type)
      end
    end

    building = model.getBuilding

    unless building.defaultConstructionSet.empty?
      set = building.defaultConstructionSet.get
      return set if holdsConstruction?(set, base, ground, exterior, type)
    end

    nil
  end

  ##
  # Validate if every material in a layered construction is standard & opaque.
  #
  # @param lc [OpenStudio::LayeredConstruction] a layered construction
  #
  # @return [Bool] true if all layers are valid
  # @return [Bool] false if invalid input
  def standardOpaqueLayers?(lc)
    cl = OpenStudio::Model::LayeredConstruction

    unless lc
      Outilities.log(Outilities::ERROR,
        "Invalid argument in Outilities::standardOpaqueLayers?")
      return false
    end
    unless lc.is_a?(cl)
      Outilities.log(Outilities::ERROR,
        "#{lc.class}? expecting #{cl} in Outilities::standardOpaqueLayers?")
      return false
    end

    lc.layers.each { |m| return false if m.to_StandardOpaqueMaterial.empty? }
    true
  end

  ##
  # Total (standard opaque) layered construction thickness (in m).
  #
  # @param lc [OpenStudio::LayeredConstruction] a layered construction
  #
  # @return [Double] total layered construction thickness
  # @return [Double] 0 if invalid input
  def thickness(lc)
    cl = OpenStudio::Model::LayeredConstruction

    unless lc
      Outilities.log(Outilities::ERROR,
        "Invalid argument in Outilities::thickness")
      return 0
    end
    unless lc.is_a?(cl)
      Outilities.log(Outilities::ERROR,
        "#{lc.class}? expecting #{cl} in Outilities::thickness")
      return 0
    end
    unless standardOpaqueLayers?(lc)
      Outilities.log(Outilities::ERROR,
        "#{lc.nameString} holds invalid material(s), Outilities::thickness")
      return 0
    end

    thickness = 0.0
    lc.layers.each { |m| thickness += m.thickness }
    thickness
  end
end
