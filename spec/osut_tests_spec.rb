require "osut"

RSpec.describe OSut do
  TOL  = OSut::TOL
  DBG  = OSut::DEBUG
  INF  = OSut::INFO
  WRN  = OSut::WARN
  ERR  = OSut::ERR
  FTL  = OSut::FATAL

  let(:cls1) { Class.new  { extend OSut } }
  let(:cls2) { Class.new  { extend OSut } }
  let(:mod1) { Module.new { extend OSut } }

  it "checks scheduleRulesetMinMax (from within class instances)" do
    translator = OpenStudio::OSVersion::VersionTranslator.new
    file = File.join(__dir__, "files/osms/in/seb.osm")
    path = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model.empty?).to be(false)
    model = model.get

    expect(cls1.level).to eq(INF)
    expect(cls1.reset(DBG)).to eq(DBG)
    expect(cls1.level).to eq(DBG)
    expect(cls1.clean!).to eq(DBG)

    sc1 = "Space Thermostat Cooling Setpoint"
    sc2 = "Schedule Constant 1"
    cl1 = OpenStudio::Model::ScheduleRuleset
    cl2 = OpenStudio::Model::ScheduleConstant
    m1  = "Invalid 'sched' arg #1 (OSut::scheduleRulesetMinMax)"
    m2  = "'#{sc2}' #{cl2}? expecting #{cl1} (OSut::scheduleRulesetMinMax)"

    sched = model.getScheduleRulesetByName(sc1)
    expect(sched.empty?).to be(false)
    sched = sched.get
    expect(sched.is_a?(cl1)).to be(true)

    sch = model.getScheduleConstantByName(sc2)
    expect(sch.empty?).to be(false)
    sch = sch.get
    expect(sch.is_a?(cl2)).to be(true)

    # Valid case.
    minmax = cls1.scheduleRulesetMinMax(sched)
    expect(minmax.is_a?(Hash)).to be(true)
    expect(minmax.key?(:min)).to be(true)
    expect(minmax.key?(:max)).to be(true)
    expect(minmax[:min]).to be_within(TOL).of(23.89)
    expect(minmax[:min]).to be_within(TOL).of(23.89)
    expect(cls1.status.zero?).to be(true)
    expect(cls1.logs.empty?).to be(true)

    # Invalid parameter.
    minmax = cls1.scheduleRulesetMinMax(nil)
    expect(minmax.is_a?(Hash)).to be(true)
    expect(minmax.key?(:min)).to be(true)
    expect(minmax.key?(:max)).to be(true)
    expect(minmax[:min].nil?).to be(true)
    expect(minmax[:max].nil?).to be(true)
    expect(cls1.debug?).to be(true)
    expect(cls1.logs.size).to eq(1)
    expect(cls1.logs.first[:message]).to eq(m1)

    expect(cls1.clean!).to eq(DBG)

    # Invalid parameter.
    minmax = cls1.scheduleRulesetMinMax(model)
    expect(minmax.is_a?(Hash)).to be(true)
    expect(minmax.key?(:min)).to be(true)
    expect(minmax.key?(:max)).to be(true)
    expect(minmax[:min].nil?).to be(true)
    expect(minmax[:max].nil?).to be(true)
    expect(cls1.debug?).to be(true)
    expect(cls1.logs.size).to eq(1)
    expect(cls1.logs.first[:message]).to eq(m1)

    expect(cls1.clean!).to eq(DBG)

    # Invalid parameter (wrong schedule type)
    minmax = cls1.scheduleRulesetMinMax(sch)
    expect(minmax.is_a?(Hash)).to be(true)
    expect(minmax.key?(:min)).to be(true)
    expect(minmax.key?(:max)).to be(true)
    expect(minmax[:min].nil?).to be(true)
    expect(minmax[:max].nil?).to be(true)
    expect(cls1.debug?).to be(true)
    expect(cls1.logs.size).to eq(1)
    expect(cls1.logs.first[:message]).to eq(m2)
  end

  it "checks scheduleConstantMinMax" do
    translator = OpenStudio::OSVersion::VersionTranslator.new
    file = File.join(__dir__, "files/osms/in/seb.osm")
    path = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model.empty?).to be(false)
    model = model.get

    expect(cls1.clean!).to eq(DBG)

    sc1 = "Schedule Constant 1"
    sc2 = "Space Thermostat Cooling Setpoint"
    cl1 = OpenStudio::Model::ScheduleConstant
    cl2 = OpenStudio::Model::ScheduleRuleset
    m1  = "Invalid 'sched' arg #1 (OSut::scheduleConstantMinMax)"
    m2  = "'#{sc2}' #{cl2}? expecting #{cl1} (OSut::scheduleConstantMinMax)"

    sched = model.getScheduleConstantByName(sc1)
    expect(sched.empty?).to be(false)
    sched = sched.get
    expect(sched.is_a?(cl1)).to be(true)

    sch = model.getScheduleRulesetByName(sc2)
    expect(sch.empty?).to be(false)
    sch = sch.get
    expect(sch.is_a?(cl2)).to be(true)

    # Valid case.
    minmax = cls1.scheduleConstantMinMax(sched)
    expect(minmax.is_a?(Hash)).to be(true)
    expect(minmax.key?(:min)).to be(true)
    expect(minmax.key?(:max)).to be(true)
    expect(minmax[:min]).to be_within(TOL).of(139.88)
    expect(minmax[:min]).to be_within(TOL).of(139.88)
    expect(cls1.status.zero?).to be(true)
    expect(cls1.logs.empty?).to be(true)

    # Invalid parameter.
    minmax = cls1.scheduleConstantMinMax(nil)
    expect(minmax.is_a?(Hash)).to be(true)
    expect(minmax.key?(:min)).to be(true)
    expect(minmax.key?(:max)).to be(true)
    expect(minmax[:min].nil?).to be(true)
    expect(minmax[:max].nil?).to be(true)
    expect(cls1.debug?).to be(true)
    expect(cls1.logs.size).to eq(1)
    expect(cls1.logs.first[:message]).to eq(m1)

    expect(cls1.clean!).to eq(DBG)

    # Invalid parameter.
    minmax = cls1.scheduleConstantMinMax(model)
    expect(minmax.is_a?(Hash)).to be(true)
    expect(minmax.key?(:min)).to be(true)
    expect(minmax.key?(:max)).to be(true)
    expect(minmax[:min].nil?).to be(true)
    expect(minmax[:max].nil?).to be(true)
    expect(cls1.debug?).to be(true)
    expect(cls1.logs.size).to eq(1)
    expect(cls1.logs.first[:message]).to eq(m1)

    expect(cls1.clean!).to eq(DBG)

    # Invalid parameter (wrong schedule type)
    minmax = cls1.scheduleConstantMinMax(sch)
    expect(minmax.is_a?(Hash)).to be(true)
    expect(minmax.key?(:min)).to be(true)
    expect(minmax.key?(:max)).to be(true)
    expect(minmax[:min].nil?).to be(true)
    expect(minmax[:max].nil?).to be(true)
    expect(cls1.debug?).to be(true)
    expect(cls1.logs.size).to eq(1)
    expect(cls1.logs.first[:message]).to eq(m2)
  end

  it "checks scheduleCompactMinMax (from within module instances)" do
    translator = OpenStudio::OSVersion::VersionTranslator.new
    file = File.join(__dir__, "files/osms/in/seb.osm")
    path = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model.empty?).to be(false)
    model = model.get

    expect(mod1.clean!).to eq(DBG)

    spt = 22
    sc2 = "Building HVAC Operation"
    cl1 = OpenStudio::Model::ScheduleCompact
    cl2 = OpenStudio::Model::Schedule

    m1 = "Invalid 'sched' arg #1 (OSut::scheduleCompactMinMax)"
    m2 = "'#{sc2}' #{cl2}? expecting #{cl1} (OSut::scheduleCompactMinMax)"

    sched = OpenStudio::Model::ScheduleCompact.new(model, spt)
    expect(sched.is_a?(OpenStudio::Model::ScheduleCompact)).to be(true)
    sched.setName("compact schedule")

    sch = model.getScheduleByName(sc2)
    expect(sch.empty?).to be(false)
    sch = sch.get

    # Valid case.
    minmax = mod1.scheduleCompactMinMax(sched)
    expect(minmax.is_a?(Hash)).to be(true)
    expect(minmax.key?(:min)).to be(true)
    expect(minmax.key?(:max)).to be(true)
    expect(minmax[:min]).to be_within(TOL).of(spt)
    expect(minmax[:min]).to be_within(TOL).of(spt)
    expect(mod1.status.zero?).to be(true)
    expect(mod1.logs.empty?).to be(true)

    # Invalid parameter.
    minmax = mod1.scheduleCompactMinMax(nil)
    expect(minmax.is_a?(Hash)).to be(true)
    expect(minmax.key?(:min)).to be(true)
    expect(minmax.key?(:max)).to be(true)
    expect(minmax[:min].nil?).to be(true)
    expect(minmax[:max].nil?).to be(true)
    expect(mod1.debug?).to be(true)
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m1)

    expect(mod1.clean!).to eq(DBG)

    # Invalid parameter.
    minmax = mod1.scheduleCompactMinMax(model)
    expect(minmax.is_a?(Hash)).to be(true)
    expect(minmax.key?(:min)).to be(true)
    expect(minmax.key?(:max)).to be(true)
    expect(minmax[:min].nil?).to be(true)
    expect(minmax[:max].nil?).to be(true)
    expect(mod1.debug?).to be(true)
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m1)

    expect(mod1.clean!).to eq(DBG)

    # Invalid parameter (wrong schedule type)
    minmax = mod1.scheduleCompactMinMax(sch)
    expect(minmax.is_a?(Hash)).to be(true)
    expect(minmax.key?(:min)).to be(true)
    expect(minmax.key?(:max)).to be(true)
    expect(minmax[:min].nil?).to be(true)
    expect(minmax[:max].nil?).to be(true)
    expect(mod1.debug?).to be(true)
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m2)
  end

  it "checks min/max heat/cool scheduled setpoints (as a module method)" do
    module M
      extend OSut
    end

    translator = OpenStudio::OSVersion::VersionTranslator.new
    file = File.join(__dir__, "files/osms/in/seb.osm")
    path = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model.empty?).to be(false)
    model = model.get

    expect(M.clean!).to eq(DBG)

    m1 = "OSut::maxHeatScheduledSetpoint"
    m2 = "OSut::minCoolScheduledSetpoint"
    z1 = "Level 0 Ceiling Plenum Zone"
    z2 = "Single zone"

    model.getThermalZones.each do |z|
      res = M.maxHeatScheduledSetpoint(z)
      expect(res.is_a?(Hash)).to be(true)
      expect(res.key?(:spt)).to be(true)
      expect(res.key?(:dual)).to be(true)
      expect(res[:spt].nil?).to be(true)            if z.nameString == z1
      expect(res[:spt]).to be_within(TOL).of(22.11) if z.nameString == z2
      expect(res[:dual]).to eq(false)               if z.nameString == z1
      expect(res[:dual]).to eq(true)                if z.nameString == z2
      expect(M.status.zero?).to be(true)

      res = M.minCoolScheduledSetpoint(z)
      expect(res.is_a?(Hash)).to be(true)
      expect(res.key?(:spt)).to be(true)
      expect(res.key?(:dual)).to be(true)
      expect(res[:spt].nil?).to be(true)            if z.nameString == z1
      expect(res[:spt]).to be_within(TOL).of(22.78) if z.nameString == z2
      expect(res[:dual]).to eq(false)               if z.nameString == z1
      expect(res[:dual]).to eq(true)                if z.nameString == z2
      expect(M.status.zero?).to be(true)
    end

    res = M.maxHeatScheduledSetpoint(nil)                      # bad argument
    expect(res.is_a?(Hash)).to be(true)
    expect(res.key?(:spt)).to be(true)
    expect(res.key?(:dual)).to be(true)
    expect(res[:spt].nil?).to be(true)
    expect(res[:dual]).to eq(false)
    expect(M.debug?).to be(true)
    expect(M.logs.size).to eq(1)
    expect(M.logs.first[:message]).to eq("Invalid 'zone' arg #1 (#{m1})")
    expect(M.clean!).to eq(DBG)

    res = M.minCoolScheduledSetpoint(nil)                      # bad argument
    expect(res.is_a?(Hash)).to be(true)
    expect(res.key?(:spt)).to be(true)
    expect(res.key?(:dual)).to be(true)
    expect(res[:spt].nil?).to be(true)
    expect(res[:dual]).to eq(false)
    expect(M.debug?).to be(true)
    expect(M.logs.size).to eq(1)
    expect(M.logs.first[:message]).to eq("Invalid 'zone' arg #1 (#{m2})")
    expect(M.clean!).to eq(DBG)

    res = M.maxHeatScheduledSetpoint(model)                    # bad argument
    expect(res.is_a?(Hash)).to be(true)
    expect(res.key?(:spt)).to be(true)
    expect(res.key?(:dual)).to be(true)
    expect(res[:spt].nil?).to be(true)
    expect(res[:dual]).to eq(false)
    expect(M.debug?).to be(true)
    expect(M.logs.size).to eq(1)
    expect(M.logs.first[:message]).to eq("Invalid 'zone' arg #1 (#{m1})")
    expect(M.clean!).to eq(DBG)

    res = M.minCoolScheduledSetpoint(model)                    # bad argument
    expect(res.is_a?(Hash)).to be(true)
    expect(res.key?(:spt)).to be(true)
    expect(res.key?(:dual)).to be(true)
    expect(res[:spt].nil?).to be(true)
    expect(res[:dual]).to eq(false)
    expect(M.debug?).to be(true)
    expect(M.logs.size).to eq(1)
    expect(M.logs.first[:message]).to eq("Invalid 'zone' arg #1 (#{m2})")
    expect(M.clean!).to eq(DBG)
  end

  it "checks if zones have heating/cooling temperature setpoints" do
    translator = OpenStudio::OSVersion::VersionTranslator.new
    file = File.join(__dir__, "files/osms/in/seb.osm")
    path = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model.empty?).to be(false)
    model = model.get

    cl1 = OpenStudio::Model::Model
    cl2 = NilClass
    m1 = "'model' #{cl2}? expecting #{cl1} (OSut::heatingTemperatureSetpoints?)"
    m2 = "'model' #{cl2}? expecting #{cl1} (OSut::coolingTemperatureSetpoints?)"

    expect(mod1.clean!).to eq(DBG)
    expect(mod1.heatingTemperatureSetpoints?(model)).to be(true)
    expect(mod1.status.zero?).to be(true)

    expect(mod1.coolingTemperatureSetpoints?(model)).to be(true)
    expect(mod1.status.zero?).to be(true)

    expect(mod1.heatingTemperatureSetpoints?(nil)).to be(false)   # bad argument
    expect(mod1.debug?).to be(true)
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m1)

    expect(mod1.clean!).to eq(DBG)
    expect(mod1.coolingTemperatureSetpoints?(nil)).to be(false)   # bad argument
    expect(mod1.debug?).to be(true)
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m2)
  end

  it "checks for HVAC air loops" do
    translator = OpenStudio::OSVersion::VersionTranslator.new
    file = File.join(__dir__, "files/osms/in/seb.osm")
    path = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model.empty?).to be(false)
    model = model.get

    cl1 = OpenStudio::Model::Model
    cl2 = NilClass
    m = "'model' #{cl2}? expecting #{cl1} (OSut::airLoopsHVAC?)"

    expect(mod1.clean!).to eq(DBG)
    expect(mod1.airLoopsHVAC?(model)).to be(true)
    expect(mod1.status.zero?).to be(true)

    expect(mod1.airLoopsHVAC?(nil)).to be(false)
    expect(mod1.debug?).to be(true)
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m)

    file = File.join(__dir__, "files/osms/in/5ZoneNoHVAC.osm")
    path = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model.empty?).to be(false)
    model = model.get

    expect(mod1.clean!).to eq(DBG)
    expect(mod1.airLoopsHVAC?(model)).to be(false)
    expect(mod1.status.zero?).to be(true)

    expect(mod1.airLoopsHVAC?(nil)).to be(false)
    expect(mod1.debug?).to be(true)
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m)
  end

  it "checks for plenums" do
    translator = OpenStudio::OSVersion::VersionTranslator.new
    file = File.join(__dir__, "files/osms/in/seb.osm")
    path = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model.empty?).to be(false)
    model = model.get

    m  = "OSut::plenum?"
    m1 = "Invalid 'space' arg #1 (#{m})"
    sp = "Level 0 Ceiling Plenum"

    expect(mod1.clean!).to eq(DBG)
    loops = mod1.airLoopsHVAC?(model)
    expect(loops).to be(true)
    expect(mod1.status.zero?).to be(true)
    setpoints = mod1.heatingTemperatureSetpoints?(model)
    expect(setpoints).to be(true)
    expect(mod1.status.zero?).to be(true)

    model.getSpaces.each do |space|
      id = space.nameString
      expect(mod1.plenum?(space, loops, setpoints)).to be(false)     if id == sp
      expect(mod1.plenum?(space, loops, setpoints)).to be(false) unless id == sp
    end

    expect(mod1.status.zero?).to be(true)
    expect(mod1.plenum?(nil, loops, setpoints)).to be(false)
    expect(mod1.debug?).to be(true)
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m1)


    file = File.join(__dir__, "files/osms/in/5ZoneNoHVAC.osm")
    path = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model.empty?).to be(false)
    model = model.get
    expect(mod1.clean!).to eq(DBG)
    loops = mod1.airLoopsHVAC?(model)
    expect(loops).to be(false)
    expect(mod1.status.zero?).to be(true)
    setpoints = mod1.heatingTemperatureSetpoints?(model)
    expect(setpoints).to be(true)
    expect(mod1.status.zero?).to be(true)

    model.getSpaces.each do |space|
      expect(mod1.plenum?(space, loops, setpoints)).to be(false)
    end

    expect(mod1.status.zero?).to be(true)


    file = File.join(__dir__, "files/osms/in/smalloffice.osm")
    path = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model.empty?).to be(false)
    model = model.get

    expect(mod1.clean!).to eq(DBG)
    loops = mod1.airLoopsHVAC?(model)
    expect(loops).to be(true)
    expect(mod1.status.zero?).to be(true)
    setpoints = mod1.heatingTemperatureSetpoints?(model)
    expect(setpoints).to be(true)
    expect(mod1.status.zero?).to be(true)

    model.getSpaces.each do |space|
      id = space.nameString
      expect(space.thermalZone.empty?).to be(false)
      zone = space.thermalZone.get

      heat_spt = mod1.maxHeatScheduledSetpoint(zone)
      cool_spt = mod1.minCoolScheduledSetpoint(zone)
      expect(heat_spt.is_a?(Hash)).to be(true)
      expect(cool_spt.is_a?(Hash)).to be(true)
      expect(heat_spt.key?(:spt)).to be(true)
      expect(cool_spt.key?(:spt)).to be(true)
      expect(heat_spt.key?(:dual)).to be(true)
      expect(cool_spt.key?(:dual)).to be(true)
      expect(heat_spt[:spt].nil?).to be(true)                   if id == "Attic"
      expect(cool_spt[:spt].nil?).to be(true)                   if id == "Attic"
      expect(heat_spt[:dual]).to be(false)                      if id == "Attic"
      expect(cool_spt[:dual]).to be(false)                      if id == "Attic"
      expect(zone.thermostat.empty?)                            if id == "Attic"
      expect(space.partofTotalFloorArea).to be(true)        unless id == "Attic"
      expect(space.partofTotalFloorArea).to be(false)           if id == "Attic"
      expect(mod1.plenum?(space, loops, setpoints)).to be(false)
    end

    expect(mod1.status.zero?).to be(true)
  end

  it "checks availability schedule generation" do
    translator = OpenStudio::OSVersion::VersionTranslator.new
    file = File.join(__dir__, "files/osms/in/seb.osm")
    path = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model.empty?).to be(false)
    model = model.get

    mdl = OpenStudio::Model::Model.new
    version = mdl.getVersion.versionIdentifier.split('.').map(&:to_i)
    v = version.join.to_i

    year = model.yearDescription
    expect(year.empty?).to be(false)
    year = year.get

    am01 = OpenStudio::Time.new(0, 1)
    pm11 = OpenStudio::Time.new(0,23)

    jan01 = year.makeDate(OpenStudio::MonthOfYear.new("Jan"),  1)
    apr30 = year.makeDate(OpenStudio::MonthOfYear.new("Apr"), 30)
    may01 = year.makeDate(OpenStudio::MonthOfYear.new("May"),  1)
    oct31 = year.makeDate(OpenStudio::MonthOfYear.new("Oct"), 31)
    nov01 = year.makeDate(OpenStudio::MonthOfYear.new("Nov"),  1)
    dec31 = year.makeDate(OpenStudio::MonthOfYear.new("Dec"), 31)
    expect(oct31.is_a?(OpenStudio::Date)).to be(true)

    expect(mod1.clean!).to eq(DBG)

    sch = mod1.availabilitySchedule(model)                        # ON (default)
    expect(sch.is_a?(OpenStudio::Model::ScheduleRuleset)).to be(true)
    expect(sch.nameString).to eq("ON Availability SchedRuleset")
    limits = sch.scheduleTypeLimits
    expect(limits.empty?).to be(false)
    limits = limits.get
    expect(limits.nameString).to eq("HVAC Operation ScheduleTypeLimits")
    default = sch.defaultDaySchedule
    expect(default.nameString).to eq("ON Availability dftDaySched")
    expect(default.times.empty?).to be(false)
    expect(default.values.empty?).to be(false)
    expect(default.times.size).to eq(1)
    expect(default.values.size).to eq(1)
    expect(default.getValue(am01).to_i).to eq(1)
    expect(default.getValue(pm11).to_i).to eq(1)
    expect(sch.isWinterDesignDayScheduleDefaulted).to be(true)
    expect(sch.isSummerDesignDayScheduleDefaulted).to be(true)
    expect(sch.isHolidayScheduleDefaulted).to be(true)
    expect(sch.isCustomDay1ScheduleDefaulted).to be(true) unless v < 330
    expect(sch.isCustomDay2ScheduleDefaulted).to be(true) unless v < 330
    expect(sch.summerDesignDaySchedule).to eq(default)
    expect(sch.winterDesignDaySchedule).to eq(default)
    expect(sch.holidaySchedule).to eq(default)
    expect(sch.customDay1Schedule).to eq(default) unless v < 330
    expect(sch.customDay2Schedule).to eq(default) unless v < 330
    expect(sch.scheduleRules.empty?).to be(true)

    sch = mod1.availabilitySchedule(model, "Off")
    expect(sch.is_a?(OpenStudio::Model::ScheduleRuleset)).to be(true)
    expect(sch.nameString).to eq("OFF Availability SchedRuleset")
    limits = sch.scheduleTypeLimits
    expect(limits.empty?).to be(false)
    limits = limits.get
    expect(limits.nameString).to eq("HVAC Operation ScheduleTypeLimits")
    default = sch.defaultDaySchedule
    expect(default.nameString).to eq("OFF Availability dftDaySched")
    expect(default.times.empty?).to be(false)
    expect(default.values.empty?).to be(false)
    expect(default.times.size).to eq(1)
    expect(default.values.size).to eq(1)
    expect(default.getValue(am01).to_i).to eq(0)
    expect(default.getValue(pm11).to_i).to eq(0)
    expect(sch.isWinterDesignDayScheduleDefaulted).to be(true)
    expect(sch.isSummerDesignDayScheduleDefaulted).to be(true)
    expect(sch.isHolidayScheduleDefaulted).to be(true)
    expect(sch.isCustomDay1ScheduleDefaulted).to be(true) unless v < 330
    expect(sch.isCustomDay2ScheduleDefaulted).to be(true) unless v < 330
    expect(sch.summerDesignDaySchedule).to eq(default)
    expect(sch.winterDesignDaySchedule).to eq(default)
    expect(sch.holidaySchedule).to eq(default)
    expect(sch.customDay1Schedule).to eq(default) unless v < 330
    expect(sch.customDay2Schedule).to eq(default) unless v < 330
    expect(sch.scheduleRules.empty?).to be(true)

    sch = mod1.availabilitySchedule(model, "Winter")
    expect(sch.is_a?(OpenStudio::Model::ScheduleRuleset)).to be(true)
    expect(sch.nameString).to eq("WINTER Availability SchedRuleset")
    limits = sch.scheduleTypeLimits
    expect(limits.empty?).to be(false)
    limits = limits.get
    expect(limits.nameString).to eq("HVAC Operation ScheduleTypeLimits")
    default = sch.defaultDaySchedule
    expect(default.nameString).to eq("WINTER Availability dftDaySched")
    expect(default.times.empty?).to be(false)
    expect(default.values.empty?).to be(false)
    expect(default.times.size).to eq(1)
    expect(default.values.size).to eq(1)
    expect(default.getValue(am01).to_i).to eq(1)
    expect(default.getValue(pm11).to_i).to eq(1)
    expect(sch.isWinterDesignDayScheduleDefaulted).to be(true)
    expect(sch.isSummerDesignDayScheduleDefaulted).to be(true)
    expect(sch.isHolidayScheduleDefaulted).to be(true)
    expect(sch.isCustomDay1ScheduleDefaulted).to be(true) unless v < 330
    expect(sch.isCustomDay2ScheduleDefaulted).to be(true) unless v < 330
    expect(sch.summerDesignDaySchedule).to eq(default)
    expect(sch.winterDesignDaySchedule).to eq(default)
    expect(sch.holidaySchedule).to eq(default)
    expect(sch.customDay1Schedule).to eq(default) unless v < 330
    expect(sch.customDay2Schedule).to eq(default) unless v < 330
    expect(sch.scheduleRules.size).to eq(1)
    sch.getDaySchedules(jan01, apr30).each do |day_schedule|
      expect(day_schedule.times.empty?).to be(false)
      expect(day_schedule.values.empty?).to be(false)
      expect(day_schedule.times.size).to eq(1)
      expect(day_schedule.values.size).to eq(1)
      expect(day_schedule.getValue(am01).to_i).to eq(1)
      expect(day_schedule.getValue(pm11).to_i).to eq(1)
    end
    sch.getDaySchedules(may01, oct31).each do |day_schedule|
      expect(day_schedule.times.empty?).to be(false)
      expect(day_schedule.values.empty?).to be(false)
      expect(day_schedule.times.size).to eq(1)
      expect(day_schedule.values.size).to eq(1)
      expect(day_schedule.getValue(am01).to_i).to eq(0)
      expect(day_schedule.getValue(pm11).to_i).to eq(0)
    end
    sch.getDaySchedules(nov01, dec31).each do |day_schedule|
      expect(day_schedule.times.empty?).to be(false)
      expect(day_schedule.values.empty?).to be(false)
      expect(day_schedule.times.size).to eq(1)
      expect(day_schedule.values.size).to eq(1)
      expect(day_schedule.getValue(am01).to_i).to eq(1)
      expect(day_schedule.getValue(pm11).to_i).to eq(1)
    end

    another = mod1.availabilitySchedule(model, "Winter")
    expect(another.nameString).to eq(sch.nameString)

    sch = mod1.availabilitySchedule(model, "Summer")
    expect(sch.is_a?(OpenStudio::Model::ScheduleRuleset)).to be(true)
    expect(sch.nameString).to eq("SUMMER Availability SchedRuleset")
    limits = sch.scheduleTypeLimits
    expect(limits.empty?).to be(false)
    limits = limits.get
    expect(limits.nameString).to eq("HVAC Operation ScheduleTypeLimits")
    default = sch.defaultDaySchedule
    expect(default.nameString).to eq("SUMMER Availability dftDaySched")
    expect(default.times.empty?).to be(false)
    expect(default.values.empty?).to be(false)
    expect(default.times.size).to eq(1)
    expect(default.values.size).to eq(1)
    expect(default.getValue(am01).to_i).to eq(0)
    expect(default.getValue(pm11).to_i).to eq(0)
    expect(sch.isWinterDesignDayScheduleDefaulted).to be(true)
    expect(sch.isSummerDesignDayScheduleDefaulted).to be(true)
    expect(sch.isHolidayScheduleDefaulted).to be(true)
    expect(sch.isCustomDay1ScheduleDefaulted).to be(true) unless v < 330
    expect(sch.isCustomDay2ScheduleDefaulted).to be(true) unless v < 330
    expect(sch.summerDesignDaySchedule).to eq(default)
    expect(sch.winterDesignDaySchedule).to eq(default)
    expect(sch.holidaySchedule).to eq(default)
    expect(sch.customDay1Schedule).to eq(default) unless v < 330
    expect(sch.customDay2Schedule).to eq(default) unless v < 330
    expect(sch.scheduleRules.size).to eq(1)
    sch.getDaySchedules(jan01, apr30).each do |day_schedule|
      expect(day_schedule.times.empty?).to be(false)
      expect(day_schedule.values.empty?).to be(false)
      expect(day_schedule.times.size).to eq(1)
      expect(day_schedule.values.size).to eq(1)
      expect(day_schedule.getValue(am01).to_i).to eq(0)
      expect(day_schedule.getValue(pm11).to_i).to eq(0)
    end
    sch.getDaySchedules(may01, oct31).each do |day_schedule|
      expect(day_schedule.times.empty?).to be(false)
      expect(day_schedule.values.empty?).to be(false)
      expect(day_schedule.times.size).to eq(1)
      expect(day_schedule.values.size).to eq(1)
      expect(day_schedule.getValue(am01).to_i).to eq(1)
      expect(day_schedule.getValue(pm11).to_i).to eq(1)
    end
    sch.getDaySchedules(nov01, dec31).each do |day_schedule|
      expect(day_schedule.times.empty?).to be(false)
      expect(day_schedule.values.empty?).to be(false)
      expect(day_schedule.times.size).to eq(1)
      expect(day_schedule.values.size).to eq(1)
      expect(day_schedule.getValue(am01).to_i).to eq(0)
      expect(day_schedule.getValue(pm11).to_i).to eq(0)
    end
  end

  it "checks construction thickness" do
    translator = OpenStudio::OSVersion::VersionTranslator.new
    file = File.join(__dir__, "files/osms/in/seb.osm")
    path = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model.empty?).to be(false)
    model = model.get

    m  = "OSut::thickness"
    m1 = "holds non-StandardOpaqueMaterial(s) (#{m})"
    expect(cls1.clean!).to eq(DBG)

    model.getConstructions.each do |c|
      next if c.to_LayeredConstruction.empty?
      c = c.to_LayeredConstruction.get
      id = c.nameString

      # OSut 'thickness' method can only process layered constructions
      # built up with standard opaque layers, which exclude the model's
      #   - "Air Wall"-based construction
      #   - "Double pane"-based construction
      # The method returns '0' in such cases, while logging ERROR messages
      # (OSut extends OSlg logger).
      th = cls1.thickness(c)
      expect(th).to be_within(TOL).of(0) if id.include?("Air Wall")
      expect(th).to be_within(TOL).of(0) if id.include?("Double pane")
      next if id.include?("Air Wall")
      next if id.include?("Double pane")
      expect(th > 0).to be(true)
    end

    expect(cls1.status).to eq(ERR)
    expect(cls1.logs.size).to eq(2)
    cls1.logs.each { |l| expect(l[:message].include?(m1)).to be(true) }

    # OSut, and by extension OSlg, are intended to be accessed "globally"
    # once instantiated within a class or module. Here, class instance cls2
    # accesses the same OSut module methods/attributes as cls1.
    expect(cls2.status).to eq(ERR)
    cls2.clean!
    expect(cls1.status.zero?).to eq(true)
    expect(cls1.logs.empty?).to be(true)

    model.getConstructions.each do |c|
      next if c.to_LayeredConstruction.empty?
      c = c.to_LayeredConstruction.get
      id = c.nameString

      # No ERROR logging if skipping over invalid arguments to 'thickness'.
      next if id.include?("Air Wall")
      next if id.include?("Double pane")
      th = cls2.thickness(c)
      expect(th > 0).to be(true)
    end

    expect(cls2.status.zero?).to be(true)
    expect(cls2.logs.empty?).to be(true)
    expect(cls1.status.zero?).to eq(true)
    expect(cls1.logs.empty?).to be(true)
  end

  it "checks if a set holds a construction" do
    translator = OpenStudio::OSVersion::VersionTranslator.new
    file = File.join(__dir__, "files/osms/in/5ZoneNoHVAC.osm")
    path = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model.empty?).to be(false)
    model = model.get

    expect(mod1.clean!).to eq(DBG)

    t1  = "roofceiling"
    t2  = "wall"
    cl1 = OpenStudio::Model::DefaultConstructionSet
    cl2 = OpenStudio::Model::LayeredConstruction
    n1  = "CBECS Before-1980 ClimateZone 8 (smoff) ConstSet"
    n2  = "CBECS Before-1980 ExtRoof IEAD ClimateZone 8"
    m1  = "'#{n2}' #{cl2}? expecting #{cl1} (OSut::holdsConstruction?)"
    m5  = "Invalid 'surface type' arg #5 (OSut::holdsConstruction?)"
    m6  = "Invalid 'set' arg #1 (OSut::holdsConstruction?)"

    set = model.getDefaultConstructionSetByName(n1)
    expect(set.empty?).to be(false)
    set = set.get

    c = model.getLayeredConstructionByName(n2)
    expect(c.empty?).to be(false)
    c = c.get

    # TRUE case: 'set' holds 'c' (exterior roofceiling construction)
    expect(mod1.holdsConstruction?(set, c, false, true, t1)).to be(true)
    expect(mod1.logs.empty?).to be(true)

    # FALSE case: not ground construction
    expect(mod1.holdsConstruction?(set, c, true, true, t1)).to be(false)
    expect(mod1.logs.empty?).to be(true)

    # INVALID case: arg #5 : nil (instead of surface type string)
    expect(mod1.holdsConstruction?(set, c, true, true, nil)).to be(false)
    expect(mod1.debug?).to be(true)
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m5)
    expect(mod1.clean!).to eq(DBG)

    # INVALID case: arg #5 : empty surface type string
    expect(mod1.holdsConstruction?(set, c, true, true, "")).to be(false)
    expect(mod1.debug?).to be(true)
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m5)
    expect(mod1.clean!).to eq(DBG)

    # INVALID case: arg #5 : c construction (instead of surface type string)
    expect(mod1.holdsConstruction?(set, c, true, true, c)).to be(false)
    expect(mod1.debug?).to be(true)
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m5)
    expect(mod1.clean!).to eq(DBG)

    # INVALID case: arg #1 : c construction (instead of surface type string)
    expect(mod1.holdsConstruction?(c, c, true, true, c)).to be(false)
    expect(mod1.debug?).to be(true)
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m1)
    expect(mod1.clean!).to eq(DBG)

    # INVALID case: arg #1 : model (instead of surface type string)
    expect(mod1.holdsConstruction?(model, c, true, true, t1)).to be(false)
    expect(mod1.debug?).to be(true)
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m6)
    expect(mod1.clean!).to eq(DBG)
  end

  it "retrieves a surface default construction set" do
    translator = OpenStudio::OSVersion::VersionTranslator.new
    file = File.join(__dir__, "files/osms/in/5ZoneNoHVAC.osm")
    path = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model.empty?).to be(false)
    model = model.get

    m = "construction not defaulted (defaultConstructionSet)"
    mod1.clean!

    model.getSurfaces.each do |s|
      set = mod1.defaultConstructionSet(model, s)
      expect(set.nil?).to be(false)
      expect(mod1.status.zero?).to be(true)
      expect(mod1.logs.empty?).to be(true)
    end

    translator = OpenStudio::OSVersion::VersionTranslator.new
    file = File.join(__dir__, "files/osms/in/seb.osm")
    path = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model.empty?).to be(false)
    model = model.get

    mod1.clean!

    model.getSurfaces.each do |s|
      set = mod1.defaultConstructionSet(model, s)
      expect(set.nil?).to be(true)
      expect(mod1.status).to eq(ERR)

      mod1.logs.each {|l| expect(l[:message].include?(m)) }
    end
  end

  it "checks glazing airfilms" do
    translator = OpenStudio::OSVersion::VersionTranslator.new
    file = File.join(__dir__, "files/osms/in/seb.osm")
    path = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model.empty?).to be(false)
    model = model.get

    m  = "OSut::glazingAirFilmRSi"
    m1 = "Invalid 'usi' arg #1 (#{m})"
    m2 = "'usi' String? expecting Numeric (#{m})"
    m3 = "'usi' NilClass? expecting Numeric (#{m})"
    expect(mod1.clean!).to eq(DBG)

    model.getConstructions.each do |c|
      next unless c.isFenestration
      expect(c.uFactor.empty?).to be(false)
      expect(c.uFactor.get.is_a?(Numeric)).to be(true)
      expect(mod1.glazingAirFilmRSi(c.uFactor.get)).to be_within(TOL).of(0.17)
      expect(mod1.status.zero?).to be(true)
    end

    expect(mod1.glazingAirFilmRSi(9.0)).to be_within(TOL).of(0.1216)
    expect(mod1.warn?).to be(true)
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m1)

    expect(mod1.clean!).to eq(DBG)
    expect(mod1.glazingAirFilmRSi("")).to be_within(TOL).of(0.1216)
    expect(mod1.debug?).to be(true)
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m2)

    expect(mod1.clean!).to eq(DBG)
    expect(mod1.glazingAirFilmRSi(nil)).to be_within(TOL).of(0.1216)
    expect(mod1.debug?).to be(true)
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m3)
  end

  it "checks rsi calculations" do
    translator = OpenStudio::OSVersion::VersionTranslator.new
    file = File.join(__dir__, "files/osms/in/seb.osm")
    path = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model.empty?).to be(false)
    model = model.get

    m  = "OSut::rsi"
    m1 = "Invalid 'lc' arg #1 (#{m})"
    m2 = "Negative 'film' (#{m})"
    m3 = "'film' NilClass? expecting Numeric (#{m})"
    m4 = "Negative 'temp K' (#{m})"
    m5 = "'temp K' NilClass? expecting Numeric (#{m})"
    expect(mod1.clean!).to eq(DBG)

    model.getSurfaces.each do |s|
      next unless s.isPartOfEnvelope
      lc = s.construction
      expect(lc.empty?).to be(false)
      lc = lc.get.to_LayeredConstruction
      expect(lc.empty?).to be(false)
      lc = lc.get

      if s.isGroundSurface                      # 4x slabs on grade in SEB model
        expect(s.filmResistance).to be_within(TOL).of(0.160)
        expect(mod1.rsi(lc, s.filmResistance)).to be_within(TOL).of(0.448)
        expect(mod1.status.zero?).to be(true)
      else
        if s.surfaceType == "Wall"
          expect(s.filmResistance).to be_within(TOL).of(0.150)
          expect(mod1.rsi(lc, s.filmResistance)).to be_within(TOL).of(2.616)
          expect(mod1.status.zero?).to be(true)
        else                                                       # RoofCeiling
          expect(s.filmResistance).to be_within(TOL).of(0.136)
          expect(mod1.rsi(lc, s.filmResistance)).to be_within(TOL).of(5.631)
          expect(mod1.status.zero?).to be(true)
        end
      end
    end

    expect(mod1.rsi("", 0.150)).to be_within(TOL).of(0)
    expect(mod1.debug?).to be(true)
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m1)

    expect(mod1.clean!).to eq(DBG)
    expect(mod1.rsi(nil, 0.150)).to be_within(TOL).of(0)
    expect(mod1.debug?).to be(true)
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m1)

    lc = model.getLayeredConstructionByName("SLAB-ON-GRADE-FLOOR")
    expect(lc.empty?).to be(false)
    lc = lc.get

    expect(mod1.clean!).to eq(DBG)
    expect(mod1.rsi(lc, -1)).to be_within(TOL).of(0)
    expect(mod1.debug?).to be(true)
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m2)

    expect(mod1.clean!).to eq(DBG)
    expect(mod1.rsi(lc, nil)).to be_within(TOL).of(0)
    expect(mod1.debug?).to be(true)
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m3)

    expect(mod1.clean!).to eq(DBG)
    expect(mod1.rsi(lc, 0.150, -300)).to be_within(TOL).of(0)
    expect(mod1.debug?).to be(true)
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m4)

    expect(mod1.clean!).to eq(DBG)
    expect(mod1.rsi(lc, 0.150, nil)).to be_within(TOL).of(0)
    expect(mod1.debug?).to be(true)
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m5)
  end

  it "identifies an (opaque) insulating layer within a layered construction" do
    translator = OpenStudio::OSVersion::VersionTranslator.new
    file = File.join(__dir__, "files/osms/in/seb.osm")
    path = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model.empty?).to be(false)
    model = model.get

    m  = "OSut::insulatingLayer"
    m1 = "Invalid 'lc' arg #1 (#{m})"
    expect(mod1.clean!).to eq(DBG)

    model.getLayeredConstructions.each do |lc|
      lyr = mod1.insulatingLayer(lc)
      expect(lyr.is_a?(Hash)).to be(true)
      expect(lyr.key?(:index)).to be(true)
      expect(lyr.key?(:type)).to be(true)
      expect(lyr.key?(:r)).to be(true)

      if lc.isFenestration
        expect(mod1.status.zero?).to be(true)
        expect(lyr[:index].nil?).to be(true)
        expect(lyr[:type].nil?).to be(true)
        expect(lyr[:r].zero?).to be(true)
        next
      end

      unless lyr[:type] == :standard || lyr[:type] == :massless   # air wall mat
        expect(mod1.status.zero?).to be(true)
        expect(lyr[:index].nil?).to be(true)
        expect(lyr[:type].nil?).to be(true)
        expect(lyr[:r].zero?).to be(true)
        next
      end

      expect(lyr[:index] < lc.numLayers).to be(true)

      case lc.nameString
      when "EXTERIOR-ROOF"
        expect(lyr[:index]).to eq(2)
        expect(lyr[:r]).to be_within(TOL).of(5.08)
      when "EXTERIOR-WALL"
        expect(lyr[:index]).to eq(2)
        expect(lyr[:r]).to be_within(TOL).of(1.47)
      when "Default interior ceiling"
        expect(lyr[:index]).to eq(0)
        expect(lyr[:r]).to be_within(TOL).of(0.12)
      when "INTERIOR-WALL"
        expect(lyr[:index]).to eq(1)
        expect(lyr[:r]).to be_within(TOL).of(0.24)
      else
        expect(lyr[:index]).to eq(0)
        expect(lyr[:r]).to be_within(TOL).of(0.29)
      end
    end

    lyr = mod1.insulatingLayer(nil)
    expect(mod1.debug?).to be(true)
    expect(lyr[:index].nil?).to be(true)
    expect(lyr[:type].nil?).to be(true)
    expect(lyr[:r].zero?).to be(true)
    expect(mod1.debug?).to be(true)
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m1)

    expect(mod1.clean!).to eq(DBG)
    lyr = mod1.insulatingLayer("")
    expect(mod1.debug?).to be(true)
    expect(lyr[:index].nil?).to be(true)
    expect(lyr[:type].nil?).to be(true)
    expect(lyr[:r].zero?).to be(true)
    expect(mod1.debug?).to be(true)
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m1)

    expect(mod1.clean!).to eq(DBG)
    lyr = mod1.insulatingLayer(model)
    expect(mod1.debug?).to be(true)
    expect(lyr[:index].nil?).to be(true)
    expect(lyr[:type].nil?).to be(true)
    expect(lyr[:r].zero?).to be(true)
    expect(mod1.debug?).to be(true)
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m1)
  end

  it "checks model transformation" do
    translator = OpenStudio::OSVersion::VersionTranslator.new
    file = File.join(__dir__, "files/osms/in/seb.osm")
    path = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model.empty?).to be(false)
    model = model.get

    m  = "OSut::transforms"
    m1 = "Invalid 'group' arg #2 (#{m})"
    expect(mod1.clean!).to eq(DBG)

    model.getSpaces.each do |space|
      tr = mod1.transforms(model, space)
      expect(tr.is_a?(Hash)).to be(true)
      expect(tr.key?(:t)).to be(true)
      expect(tr.key?(:r)).to be(true)
      expect(tr[:t].is_a?(OpenStudio::Transformation)).to be(true)
      expect(tr[:r]).to within(TOL).of(0)
    end

    expect(mod1.status.zero?).to be(true)

    translator = OpenStudio::OSVersion::VersionTranslator.new
    file = File.join(__dir__, "files/osms/in/5ZoneNoHVAC.osm")
    path = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model.empty?).to be(false)
    model = model.get

    model.getSpaces.each do |space|
      tr = mod1.transforms(model, space)
      expect(tr.is_a?(Hash)).to be(true)
      expect(tr.key?(:t)).to be(true)
      expect(tr.key?(:r)).to be(true)
      expect(tr[:t].is_a?(OpenStudio::Transformation)).to be(true)
      expect(tr[:r]).to within(TOL).of(0)
    end

    expect(mod1.status.zero?).to be(true)

    tr = mod1.transforms(model, nil)
    expect(tr.is_a?(Hash)).to be(true)
    expect(tr.key?(:t)).to be(true)
    expect(tr.key?(:r)).to be(true)
    expect(tr[:t].nil?).to be(true)
    expect(tr[:r].nil?).to be(true)
    expect(mod1.debug?).to be(true)
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m1)
  end

  it "checks flattened 3D points" do
    expect(mod1.reset(DBG)).to eq(DBG)
    expect(mod1.level).to eq(DBG)
    expect(mod1.clean!).to eq(DBG)

    translator = OpenStudio::OSVersion::VersionTranslator.new
    file = File.join(__dir__, "files/osms/in/seb.osm")
    path = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    model = model.get

    cl1 = OpenStudio::Model::Model
    cl2 = OpenStudio::Point3dVector
    cl3 = OpenStudio::Point3d
    cl4 = NilClass
    m   = "OSut::flatZ"
    m1  = "'points' #{cl4}? expecting #{cl2} (#{m})"
    m2  = "'points' #{cl1}? expecting #{cl2} (#{m})"

    expect(mod1.clean!).to eq(DBG)

    model.getSurfaces.each do |s|
      next unless s.isPartOfEnvelope
      next unless s.surfaceType == "RoofCeiling"
      flat = mod1.flatZ(s.vertices)
      expect(flat.is_a?(cl2)).to be(true)

      flat.each do |fv|
        expect(fv.is_a?(cl3)).to be(true)
        expect(fv.z).to be_within(TOL).of(0)
      end

      expect(s.vertices.first.x).to be_within(TOL).of(flat.first.x)
      expect(s.vertices.first.y).to be_within(TOL).of(flat.first.y)
    end

    expect(mod1.status.zero?).to be(true)
    flat = mod1.flatZ(nil)
    expect(flat.is_a?(cl2)).to be(true)
    expect(flat.empty?).to be(true)
    expect(mod1.debug?).to be(true)
    expect(mod1.logs.size).to be(1)
    expect(mod1.logs.first[:message]).to eq(m1)

    expect(mod1.clean!).to eq(DBG)
    flat = mod1.flatZ(model)
    expect(flat.is_a?(cl2)).to be(true)
    expect(flat.empty?).to be(true)
    expect(mod1.debug?).to be(true)
    expect(mod1.logs.size).to be(1)

    expect(mod1.logs.first[:message]).to eq(m2)
  end

  it "checks surface fits?' & overlaps?" do
    expect(mod1.reset(DBG)).to eq(DBG)
    expect(mod1.level).to eq(DBG)
    expect(mod1.clean!).to eq(DBG)

    version = OpenStudio.openStudioVersion.split(".").map(&:to_i).join.to_i
    model   = OpenStudio::Model::Model.new

    # 10m x 10m parent vertical (wall) surface.
    vec = OpenStudio::Point3dVector.new
    vec << OpenStudio::Point3d.new(  0,  0, 10)
    vec << OpenStudio::Point3d.new(  0,  0,  0)
    vec << OpenStudio::Point3d.new( 10,  0,  0)
    vec << OpenStudio::Point3d.new( 10,  0, 10)
    wall = OpenStudio::Model::Surface.new(vec, model)

    # XY-plane transformation matrix ... needs to be clockwise for boost.
    ft      = OpenStudio::Transformation::alignFace(wall.vertices)
    ft_wall = mod1.flatZ( (ft.inverse * wall.vertices) )
    cw      = OpenStudio::pointInPolygon(ft_wall.first, ft_wall, TOL)
    expect(cw).to be(false)
    ft_wall = mod1.flatZ( (ft.inverse * wall.vertices).reverse )       unless cw

    # 1m x 2m corner door (with 2x edges along wall edges)
    vec = OpenStudio::Point3dVector.new
    vec << OpenStudio::Point3d.new(  0,  0,  2)
    vec << OpenStudio::Point3d.new(  0,  0,  0)
    vec << OpenStudio::Point3d.new(  1,  0,  0)
    vec << OpenStudio::Point3d.new(  1,  0,  2)
    door1 = OpenStudio::Model::SubSurface.new(vec, model)

    ft_door1 = mod1.flatZ( (ft.inverse * door1.vertices).reverse )     unless cw
    ft_door1 = mod1.flatZ( (ft.inverse * door1.vertices) )                 if cw
    expect(mod1.status.zero?).to be(true)

    # Door1 fits?, overlaps?
    unless version < 340
      expect(OpenStudio.polygonInPolygon(ft_door1, ft_wall, TOL)).to be(true)
    end

    expect(mod1.fits?(door1.vertices, wall.vertices)).to be(true)
    expect(mod1.status.zero?).to be(true)
    expect(mod1.overlaps?(door1.vertices, wall.vertices)).to be(true)
    expect(mod1.status.zero?).to be(true)

    # Order of arguments matter.
    expect(mod1.fits?(wall.vertices, door1.vertices)).to be(false)
    expect(mod1.overlaps?(wall.vertices, door1.vertices)).to be(true)
    expect(mod1.status.zero?).to be(true)

    # Another 1m x 2m corner door, yet entirely beyond the wall surface.
    vec = OpenStudio::Point3dVector.new
    vec << OpenStudio::Point3d.new( 16,  0,  2)
    vec << OpenStudio::Point3d.new( 16,  0,  0)
    vec << OpenStudio::Point3d.new( 17,  0,  0)
    vec << OpenStudio::Point3d.new( 17,  0,  2)
    door2 = OpenStudio::Model::SubSurface.new(vec, model)

    # Door2 fits?, overlaps?
    expect(mod1.fits?(door2.vertices, wall.vertices)).to be(false)
    expect(mod1.overlaps?(door2.vertices, wall.vertices)).to be(false)
    expect(mod1.status.zero?).to be(true)

    # Order of arguments doesn't matter.
    expect(mod1.fits?(wall.vertices, door2.vertices)).to be(false)
    expect(mod1.overlaps?(wall.vertices, door2.vertices)).to be(false)
    expect(mod1.status.zero?).to be(true)

    # Top-right corner 2m x 2m window, overlapping top-right corner of wall.
    vec = OpenStudio::Point3dVector.new
    vec << OpenStudio::Point3d.new(  9,  0, 11)
    vec << OpenStudio::Point3d.new(  9,  0,  9)
    vec << OpenStudio::Point3d.new( 11,  0,  9)
    vec << OpenStudio::Point3d.new( 11,  0, 11)
    window = OpenStudio::Model::SubSurface.new(vec, model)

    # Window fits?, overlaps?
    expect(mod1.fits?(window.vertices, wall.vertices)).to be(false)
    expect(mod1.overlaps?(window.vertices, wall.vertices)).to be(true)
    expect(mod1.status.zero?).to be(true)

    expect(mod1.fits?(wall.vertices, window.vertices)).to be(false)
    expect(mod1.overlaps?(wall.vertices, window.vertices)).to be(true)
    expect(mod1.status.zero?).to be(true)

    # A glazed surface, entirely encompassing the wall.
    vec = OpenStudio::Point3dVector.new
    vec << OpenStudio::Point3d.new(  0,  0, 10)
    vec << OpenStudio::Point3d.new(  0,  0,  0)
    vec << OpenStudio::Point3d.new( 10,  0,  0)
    vec << OpenStudio::Point3d.new( 10,  0, 10)
    glazing = OpenStudio::Model::SubSurface.new(vec, model)

    # Glazing fits?, overlaps?
    expect(mod1.fits?(glazing.vertices, wall.vertices)).to be(true)
    expect(mod1.overlaps?(glazing.vertices, wall.vertices)).to be(true)
    expect(mod1.status.zero?).to be(true)

    expect(mod1.fits?(wall.vertices, glazing.vertices)).to be(true)
    expect(mod1.overlaps?(wall.vertices, glazing.vertices)).to be(true)
    expect(mod1.status.zero?).to be(true)
  end

  it "can safely offset with F+D" do
    expect(mod1.reset(DBG)).to eq(DBG)
    expect(mod1.level).to eq(DBG)
    expect(mod1.clean!).to eq(DBG)

    version = OpenStudio.openStudioVersion.split(".").map(&:to_i).join.to_i

    # Basic test: triangular surface with 2x acute angles.
    vec  = OpenStudio::Point3dVector.new
    vec << OpenStudio::Point3d.new(  2.00,  8.00,  0.00)
    vec << OpenStudio::Point3d.new(  1.00,  6.00,  0.00)
    vec << OpenStudio::Point3d.new(  4.00,  9.00,  0.00)

    offset = mod1.offset(vec, 0.2, 300)
    expect(mod1.status.zero?).to be(true)
    expect(offset.is_a?(Array)).to be(true)
    expect(offset.size).to eq(3)
    # offset.each { |q| puts q }                               # these check out
    #   1.85, 8.15, 0.00
    #   0.27, 4.99, 0.00
    #   5.01, 9.73, 0.00
    a1 = OpenStudio.getArea(vec)
    a2 = OpenStudio.getArea(offset)
    expect(a1.empty?).to be(false)
    expect(a2.empty?).to be(false)
    a1 = a1.get
    a2 = a2.get
    expect(a1).to be_within(TOL).of(1.50)
    expect(a2).to be_within(TOL).of(3.75)

    unless version < 321                     # accessing Boost's buffer function
      offset = mod1.offset(vec, 0.2)
      expect(mod1.status.zero?).to be(true)
      expect(offset.is_a?(Array)).to be(true)
      expect(offset.size).to eq(6)
      # offset.each { |q| puts q }                       # extra colinear points
      #   4.81, 9.58, 0.00
      #   3.91, 9.18, 0.00
      #   1.85, 8.15, 0.00
      #   0.82, 6.09, 0.00
      #   0.42, 5.19, 0.00
      #   1.14, 5.86, 0.00
      a2 = OpenStudio.getArea(offset)
      expect(a2.empty?).to be(false)
      a2 = a2.get
      expect(a2).to be_within(TOL).of(3.57) # 5% less accurate with acute angles
    end

    # Basic test: 4-sided, irregular polygon: 1x concave angle.
    vec  = OpenStudio::Point3dVector.new
    vec << OpenStudio::Point3d.new(  5.00,  2.00,  0.00)
    vec << OpenStudio::Point3d.new(  6.00,  5.00,  0.00)
    vec << OpenStudio::Point3d.new(  8.00,  3.00,  0.00)
    vec << OpenStudio::Point3d.new(  6.00,  3.00,  0.00)

    # OSut' offset method is designed for 3- or 4-sided, convex polygons (e.g.
    # OpenStudio subSurfaces) ONLY. It is NOT designed for concave polygons.
    # A reminder: OpenStudio will convert any irregular subsurface polygon to a
    # regular, 4-sided polygon in the background. This is the case for a 3-sided
    # subsurface, and/or for one with a Frame & Divider (F+D) object. So the
    # results comparison here is somewhat academic, i.e. may have little to no
    # effect on energy simulation results - it depends. But it nonetheless
    # remains relevant to ensure app stability & harmonized results.
    offset = mod1.offset(vec, 0.2, 300)
    expect(mod1.status.zero?).to be(true)
    expect(offset.is_a?(Array)).to be(true)
    expect(offset.size).to eq(4)
    # offset.each { |q| puts q }      # last vertex is off the mark, as expected
    #   4.54, 1.26, 0.00
    #   5.91, 5.37, 0.00
    #   8.48, 2.80, 0.00
    #   5.92, 3.20, 0.00               << Y: should be 2.8 (as preceding vertex)
    a1 = OpenStudio.getArea(vec)
    a2 = OpenStudio.getArea(offset)
    expect(a1.empty?).to be(false)
    expect(a2.empty?).to be(false)
    a1 = a1.get
    a2 = a2.get
    expect(a1).to be_within(TOL).of(3.00)
    expect(a2).to be_within(TOL).of(4.28) # << should be 5.2 m2, ~18% inaccuracy

    unless version < 321                     # accessing Boost's buffer function
      offset = mod1.offset(vec, 0.2)
      expect(mod1.status.zero?).to be(true)
      expect(offset.is_a?(Array)).to be(true)
      expect(offset.size).to eq(4)
      # offset.each { |q| puts q }                             # these check out
      #   4.54, 1.26, 0.00
      #   5.91, 5.37, 0.00
      #   8.48, 2.80, 0.00
      #   6.08, 2.80, 0.00
      a2 = OpenStudio.getArea(offset)
      expect(a2.empty?).to be(false)
      a2 = a2.get
      expect(a2).to be_within(TOL).of(5.20)                    # right on target
    end


    # Testing OpenStudio surfaces & subsurfaces.
    model   = OpenStudio::Model::Model.new

    # 10m x 10m parent vertical (wall) surface.
    vec  = OpenStudio::Point3dVector.new
    vec << OpenStudio::Point3d.new(  0,  0, 10)
    vec << OpenStudio::Point3d.new(  0,  0,  0)
    vec << OpenStudio::Point3d.new( 10,  0,  0)
    vec << OpenStudio::Point3d.new( 10,  0, 10)
    wall = OpenStudio::Model::Surface.new(vec, model)

    area = OpenStudio.getArea(wall.vertices)
    expect(area.empty?).to be(false)
    expect(area.get).to be_within(TOL).of(100)

    unless version < 321
      # XY-plane transformation matrix.
      ft = OpenStudio::Transformation::alignFace(wall.vertices)
      ft_wall = mod1.flatZ( (ft.inverse * wall.vertices) )
      expect(ft_wall.empty?).to be(false)
      cw      = OpenStudio::pointInPolygon(ft_wall.first, ft_wall, TOL)
      expect(cw).to be(false)
      ft_wall = mod1.flatZ( (ft.inverse * wall.vertices).reverse )     unless cw
      expect(ft_wall.empty?).to be(false)
      ft_wall = (ft.inverse * wall.vertices).reverse                   unless cw
      ft_wall = (ft.inverse * wall.vertices)                               if cw
      width   = 0.1
      offset1 = OpenStudio.buffer(ft_wall, width, TOL)
      expect(offset1.empty?).to be(false)
      offset1 = offset1.get
      offset1 =  ft * offset1                                              if cw
      offset1 = (ft * offset1).reverse                                 unless cw

      expect(mod1.status.zero?).to be(true)
      expect(offset1.is_a?(Array)).to be(true)
      expect(offset1.size).to eq(4)         # ccw, yet not in same order ... OK!
      # offset1.each { |vx| puts vx }
      # [10.1, 0, 10.1]
      # [-0.1, 0, 10.1]
      # [-0.1, 0, -0.1]
      # [10.1, 0, -0.1]
      expect(mod1.fits?(wall.vertices, offset1)).to be(true)
      expect(mod1.overlaps?(wall.vertices, offset1)).to be(true)
      expect(mod1.overlaps?(offset1, wall.vertices)).to be(true)
      area = OpenStudio.getArea(offset1)
      expect(area.empty?).to be(false)
      expect(area.get).to be_within(TOL).of(104.04)
    end

    offset2 = mod1.offset(wall.vertices, 0.1, 300)
    expect(mod1.status.zero?).to be(true)
    expect(offset2.is_a?(Array)).to be(true)
    expect(offset2.size).to eq(4)                # ccw, in same order .. better!
    # offset2.each { |vx| puts vx }
    # [-0.1, 0, 10.1]
    # [-0.1, 0, -0.1]
    # [10.1, 0, -0.1]
    # [10.1, 0, 10.1]
    expect(mod1.fits?(wall.vertices, offset2)).to be(true)
    expect(mod1.overlaps?(wall.vertices, offset2)).to be(true)
    expect(mod1.overlaps?(offset2, wall.vertices)).to be(true)
    area = OpenStudio.getArea(offset2)
    expect(area.empty?).to be(false)
    expect(area.get).to be_within(TOL).of(104.04)

    file  = File.join(__dir__, "files/osms/in/5ZoneNoHVAC.osm")
    path  = OpenStudio::Path.new(file)
    model = OpenStudio::OSVersion::VersionTranslator.new.loadModel(path)
    expect(model.empty?).to be(false)
    model = model.get

    srf2  = model.getSurfaceByName("Surface 2")
    expect(srf2.empty?).to be(false)
    srf2  = srf2.get
    #  0.000, 20.000, 3.800, !- X,Y,Z Vertex 1 {m}
    #  0.000, 20.000, 0.000, !- X,Y,Z Vertex 2 {m}
    #  0.000,  0.000, 0.000, !- X,Y,Z Vertex 3 {m}
    #  0.000,  0.000, 3.800; !- X,Y,Z Vertex 4 {m}
    v2    = srf2.vertices
    gross = srf2.grossArea
    expect(gross).to be_within(TOL).of(76.0)
    expect(srf2.netArea).to be_within(TOL).of(45.6)
    wwr = srf2.windowToWallRatio
    expect(wwr).to be_within(TOL).of(0.400)

    ss2 = model.getSubSurfaceByName("Sub Surface 2")
    expect(ss2.empty?).to be(false)
    ss2   = ss2.get
    #  0.000, 19.975, 2.284, !- X,Y,Z Vertex 1 {m}
    #  0.000, 19.975, 0.760, !- X,Y,Z Vertex 2 {m}
    #  0.000,  0.025, 0.760, !- X,Y,Z Vertex 3 {m}
    #  0.000,  0.025, 2.284; !- X,Y,Z Vertex 4 {m}
    expect(ss2.grossArea).to be_within(TOL).of(30.4)
    expect(ss2.netArea  ).to be_within(TOL).of(30.4)
    vs2 = ss2.vertices
    expect(mod1.fits?(vs2, v2)).to be(true)
    expect(mod1.overlaps?(vs2, v2)).to be(true)

    expect(gross - srf2.netArea).to be_within(TOL).of(ss2.grossArea)
    expect(ss2.allowWindowPropertyFrameAndDivider).to be(true)
    expect(ss2.windowPropertyFrameAndDivider.empty?).to be(true)

    unless version < 340                # or, e.g. ss2.respond_to?(:dividerArea)
      expect(ss2.dividerArea.to_i).to eq(0)
      expect(ss2.frameArea.to_i).to eq(0)
      expect(ss2.roughOpeningArea).to be_within(TOL).of(ss2.grossArea)

      vx2 = ss2.roughOpeningVertices     # same as original vertices without F+D
      expect(vx2.is_a?(Array)).to be(true)
      expect(vx2.empty?).to be(false)
      # vx2.each { |vxx| puts vxx }
      # [0.000, 19.975, 2.284]
      # [0.000, 19.975, 0.760]
      # [0.000,  0.025, 0.760]
      # [0.000,  0.025, 2.284]
      expect(mod1.fits?(vx2, v2)).to be(true)
      expect(mod1.overlaps?(vx2, v2)).to be(true)
    end

    # Insert 3x additional, 300mm-high windows in srf2 - siblings to ss2:
    #   - ss2a: "Sub Surface 2a": a 2m-wide clerestory - free floating
    #   - ss2b: "Sub Surface 2b": a 2m-wide clerestory - aligned along ceiling
    #   - ss2c: "Sub Surface 2c": a 2m-wide clerestory - aligned along ss2
    #
    # Neither sibling generate conflicts with parent (i.e. they all fit in),
    # nor vs each other (i.e. no overlaps, none swallows another).
    #
    # Adding a 50mm-wide Frame & Divider (F+D) to each new sibling generates:
    #   - ss2a: no conflict (safe)
    #   - ss2b: extends beyond srf2 limits
    #   - ss2c: overlaps with original ss2
    #
    # Note: set subsurface type AFTER setting its parent surface - dunno why?
    #
    # Note: F+D objects only allowed for glazed subsurface types. However,
    #       corrected WWR calculations (SDK v340+) do not consider F+D objects
    #       of glass doors.
    vec  = OpenStudio::Point3dVector.new
    vec << OpenStudio::Point3d.new( 0.000, 4.000, 3.300)
    vec << OpenStudio::Point3d.new( 0.000, 4.000, 3.000)
    vec << OpenStudio::Point3d.new( 0.000, 2.000, 3.000)
    vec << OpenStudio::Point3d.new( 0.000, 2.000, 3.300)
    ss2a = OpenStudio::Model::SubSurface.new(vec, model)
    ss2a.setName("Sub Surface 2a")
    expect(ss2a.setSurface(srf2)).to be(true)
    expect(ss2a.setSubSurfaceType("OperableWindow")).to be(true)
    expect(ss2a.netArea).to be_within(TOL).of(0.600)
    expect(ss2a.grossArea).to be_within(TOL).of(0.600)
    expect(ss2a.allowWindowPropertyFrameAndDivider).to be(true)

    vec  = OpenStudio::Point3dVector.new
    vec << OpenStudio::Point3d.new( 0.000, 8.000, 3.800)
    vec << OpenStudio::Point3d.new( 0.000, 8.000, 3.500)
    vec << OpenStudio::Point3d.new( 0.000, 6.000, 3.500)
    vec << OpenStudio::Point3d.new( 0.000, 6.000, 3.800)
    ss2b = OpenStudio::Model::SubSurface.new(vec, model)
    ss2b.setName("Sub Surface 2b")
    expect(ss2b.setSurface(srf2)).to be(true)
    expect(ss2b.setSubSurfaceType("FixedWindow")).to be(true)
    expect(ss2b.netArea).to be_within(TOL).of(0.600)
    expect(ss2b.grossArea).to be_within(TOL).of(0.600)
    expect(ss2b.allowWindowPropertyFrameAndDivider).to be(true)

    vec  = OpenStudio::Point3dVector.new
    vec << OpenStudio::Point3d.new( 0.000,12.000, 2.584)
    vec << OpenStudio::Point3d.new( 0.000,12.000, 2.284)
    vec << OpenStudio::Point3d.new( 0.000,10.000, 2.284)
    vec << OpenStudio::Point3d.new( 0.000,10.000, 2.584)
    ss2c = OpenStudio::Model::SubSurface.new(vec, model)
    ss2c.setName("Sub Surface 2c")
    expect(ss2c.setSurface(srf2)).to be(true)
    expect(ss2c.setSubSurfaceType("FixedWindow")).to be(true)
    expect(ss2c.netArea).to be_within(TOL).of(0.600)
    expect(ss2c.grossArea).to be_within(TOL).of(0.600)
    expect(ss2c.allowWindowPropertyFrameAndDivider).to be(true)

    expect(mod1.fits?( ss2.vertices, v2)).to be(true)
    expect(mod1.fits?(ss2a.vertices, v2)).to be(true)
    expect(mod1.fits?(ss2b.vertices, v2)).to be(true)
    expect(mod1.fits?(ss2c.vertices, v2)).to be(true)

    expect(mod1.overlaps?(vs2, ss2a.vertices)).to be(false)
    expect(mod1.overlaps?(vs2, ss2b.vertices)).to be(false)
    expect(mod1.overlaps?(vs2, ss2c.vertices)).to be(false)

    net   = gross
    net  -= ss2.grossArea
    net  -= ss2a.grossArea
    net  -= ss2b.grossArea
    net  -= ss2c.grossArea
    wwr3x = srf2.windowToWallRatio
    expect(srf2.netArea).to be_within(TOL).of(43.8)
    expect(wwr3x).to be_within(TOL).of(0.424)                       # before F+D

    fd = OpenStudio::Model::WindowPropertyFrameAndDivider.new(model)
    width = 0.050
    expect(fd.setFrameWidth(width)).to be(true)   # 50mm (narrow) around glazing
    expect(fd.setFrameConductance(2.500)).to be(true)

    expect(ss2a.setWindowPropertyFrameAndDivider(fd)).to be(true)
    w2a = ss2a.windowPropertyFrameAndDivider.get.frameWidth
    expect(w2a).to be_within(0.001).of(width)
    expect(ss2a.netArea).to be_within(TOL).of(0.600)
    expect(ss2a.grossArea).to be_within(TOL).of(0.600)

    unless version < 340
      # ss2a.roughOpeningVertices.each { |vx| puts vx }             # clockwise!
      # [0, 1.95, 2.95]
      # [0, 4.05, 2.95]
      # [0, 4.05, 3.35]
      # [0, 1.95, 3.35]
      expect(mod1.fits?(ss2a.roughOpeningVertices, v2)).to be(false)
      expect(mod1.fits?(ss2a.roughOpeningVertices.reverse, v2)).to be(true)
      expect(mod1.logs.empty?).to be(true)

      expect(ss2a.roughOpeningArea).to be_within(TOL).of(0.840)
      net2a  = gross
      net2a -= ss2.grossArea
      net2a -= ss2a.roughOpeningArea
      net2a -= ss2b.grossArea
      net2a -= ss2c.grossArea
      wwr2a  = srf2.windowToWallRatio
      expect(wwr2a).to be_within(TOL).of(0.427)         # not previous wwr 43.8%
      expect(srf2.netArea).to be_within(TOL).of(net2a)           # F+D accepted!

      ss2a_321 = mod1.offset(ss2a.vertices, width)
      expect(mod1.logs.empty?).to be(true)
      expect(ss2a_321.is_a?(Array)).to be(true)
      expect(ss2a_321.size).to eq(4)
      # ss2a_321.each { |vx| puts vx } # counterclockwise, reverse order vs ss2a
      # [0, 1.95, 3.35]
      # [0, 4.05, 3.35]
      # [0, 4.05, 2.95]
      # [0, 1.95, 2.95]
      ss2a_321_area = OpenStudio.getArea(ss2a_321)
      expect(ss2a_321_area.empty?).to be(false)
      expect(ss2a_321_area.get).to be_within(TOL).of(ss2a.roughOpeningArea)

      ss2a_300 = mod1.offset(ss2a.vertices, width, 300)  # oldest version tested
      expect(mod1.logs.empty?).to be(true)
      expect(ss2a_300.is_a?(Array)).to be(true)
      expect(ss2a_300.size).to eq(4)
      # ss2a_300.each { |vx| puts vx } # counterclockwise same order as original
      # [0, 4.05, 3.35]
      # [0, 4.05, 2.95]
      # [0, 1.95, 2.95]
      # [0, 1.95, 3.35]
      # vec << OpenStudio::Point3d.new( 0.000, 4.000, 3.300)
      # vec << OpenStudio::Point3d.new( 0.000, 4.000, 3.000)
      # vec << OpenStudio::Point3d.new( 0.000, 2.000, 3.000)
      # vec << OpenStudio::Point3d.new( 0.000, 2.000, 3.300)
      ss2a_300_area = OpenStudio.getArea(ss2a_300)
      expect(ss2a_300_area.empty?).to be(false)
      expect(ss2a_300_area.get).to be_within(TOL).of(ss2a.roughOpeningArea)
    end

    expect(ss2b.setWindowPropertyFrameAndDivider(fd)).to be(true)
    w2b = ss2b.windowPropertyFrameAndDivider.get.frameWidth
    expect(w2b).to be_within(TOL).of(width)
    expect(ss2b.netArea).to be_within(TOL).of(0.600)
    expect(ss2b.grossArea).to be_within(TOL).of(0.600)

    unless version < 340
      # ss2b.roughOpeningVertices.each { |vx| puts vx }             # clockwise!
      # [0, 5.95, 3.45]
      # [0, 8.05, 3.45]
      # [0, 8.05, 3.85]
      # [0, 5.95, 3.85]
      expect(mod1.fits?(ss2b.roughOpeningVertices, v2)).to be(false)
      expect(mod1.fits?(ss2b.roughOpeningVertices.reverse, v2)).to be(false)
      expect(mod1.logs.empty?).to be(true)

      # SDK will keep in memory offset vertices, even when it conflicts.
      expect(ss2b.roughOpeningArea).to be_within(TOL).of(0.840)
      net2b  = gross
      net2b -= ss2.grossArea
      net2b -= ss2a.roughOpeningArea
      net2b -= ss2b.roughOpeningArea
      net2b -= ss2c.grossArea
      wwr2b  = srf2.windowToWallRatio
      expect(wwr2b).to be_within(TOL).of(wwr2a)                 #  F+D rejected!
      expect(srf2.netArea).to be_within(TOL).of(net2b)    # updated - not net2a!

      ss2b_321 = mod1.offset(ss2b.vertices, width)
      expect(mod1.logs.empty?).to be(true)
      expect(ss2b_321.is_a?(Array)).to be(true)
      expect(ss2b_321.size).to eq(4)
      # ss2b_321.each { |vx| puts vx } # counterclockwise, reverse order vs ss2b
      # [0, 5.95, 3.85]
      # [0, 8.05, 3.85]
      # [0, 8.05, 3.45]
      # [0, 5.95, 3.45]

      ss2b_321_area = OpenStudio.getArea(ss2b_321)
      expect(ss2b_321_area.empty?).to be(false)
      expect(ss2b_321_area.get).to be_within(TOL).of(ss2b.roughOpeningArea)

      ss2b_300 = mod1.offset(ss2b.vertices, width, 300)  # oldest version tested
      expect(mod1.logs.empty?).to be(true)
      expect(ss2b_300.is_a?(Array)).to be(true)
      expect(ss2b_300.size).to eq(4)
      # ss2b_300.each { |vx| puts vx } # counterclockwise same order as original
      # [0, 8.05, 3.85]
      # [0, 8.05, 3.45]
      # [0, 5.95, 3.45]
      # [0, 5.95, 3.85]
      # vec << OpenStudio::Point3d.new( 0.000, 8.000, 3.800)
      # vec << OpenStudio::Point3d.new( 0.000, 8.000, 3.500)
      # vec << OpenStudio::Point3d.new( 0.000, 6.000, 3.500)
      # vec << OpenStudio::Point3d.new( 0.000, 6.000, 3.800)
      ss2b_300_area = OpenStudio.getArea(ss2b_300)
      expect(ss2b_300_area.empty?).to be(false)
      expect(ss2b_300_area.get).to be_within(TOL).of(ss2b.roughOpeningArea)
    end

    expect(ss2c.setWindowPropertyFrameAndDivider(fd)).to be(true)
    w2c = ss2c.windowPropertyFrameAndDivider.get.frameWidth
    expect(w2c).to be_within(TOL).of(width)
    expect(ss2c.netArea).to be_within(TOL).of(0.600)
    expect(ss2c.grossArea).to be_within(TOL).of(0.600)

    unless version < 340
      # ss2c.roughOpeningVertices.each { |vx| puts vx }             # clockwise!
      # [0,  9.95, 2.234]
      # [0, 12.05, 2.234]
      # [0, 12.05, 2.634]
      # [0,  9.95, 2.634]
      expect(mod1.fits?(ss2c.roughOpeningVertices, v2)).to be(false)
      expect(mod1.fits?(ss2c.roughOpeningVertices.reverse, v2)).to be(true)
      expect(mod1.overlaps?(ss2c.roughOpeningVertices.reverse, vs2)).to be(true)
      expect(mod1.logs.empty?).to be(true)

      # SDK will keep in memory offset vertices, even when it conflicts.
      expect(ss2b.roughOpeningArea).to be_within(TOL).of(0.840)
      net2c  = gross
      net2c -= ss2.grossArea
      net2c -= ss2a.roughOpeningArea
      net2c -= ss2b.roughOpeningArea
      net2c -= ss2c.roughOpeningArea
      wwr2c  = srf2.windowToWallRatio
      expect(wwr2c).to be_within(TOL).of(wwr2a)                 #  F+D rejected!
      expect(srf2.netArea).to be_within(TOL).of(net2c)    # updated - not net2a!

      ss2c_321 = mod1.offset(ss2c.vertices, width)
      expect(mod1.logs.empty?).to be(true)
      expect(ss2c_321.is_a?(Array)).to be(true)
      expect(ss2c_321.size).to eq(4)
      # ss2c_321.each { |vx| puts vx } # counterclockwise, reverse order vs ss2b
      # [0,  9.95, 2.634]
      # [0, 12.05, 2.634]
      # [0, 12.05, 2.234]
      # [0,  9.95, 2.234]
      expect(mod1.overlaps?(ss2c_321, vs2)).to be(true)
      ss2c_321_area = OpenStudio.getArea(ss2c_321)
      expect(ss2c_321_area.empty?).to be(false)
      expect(ss2c_321_area.get).to be_within(TOL).of(ss2c.roughOpeningArea)

      ss2c_300 = mod1.offset(ss2c.vertices, width, 300)  # oldest version tested
      expect(mod1.logs.empty?).to be(true)
      expect(ss2c_300.is_a?(Array)).to be(true)
      expect(ss2c_300.size).to eq(4)
      # ss2c_300.each { |vx| puts vx } # counterclockwise same order as original
      # [0, 12.05, 2.634]
      # [0, 12.05, 2.234]
      # [0,  9.95, 2.234]
      # [0,  9.95, 2.634]
      # vec << OpenStudio::Point3d.new( 0.000,12.000, 2.584)
      # vec << OpenStudio::Point3d.new( 0.000,12.000, 2.284)
      # vec << OpenStudio::Point3d.new( 0.000,10.000, 2.284)
      # vec << OpenStudio::Point3d.new( 0.000,10.000, 2.584)
      expect(mod1.overlaps?(ss2c_300, vs2)).to be(true)
      ss2c_300_area = OpenStudio.getArea(ss2c_300)
      expect(ss2c_300_area.empty?).to be(false)
      expect(ss2c_300_area.get).to be_within(TOL).of(ss2c.roughOpeningArea)
    end

    # Testing skylights.
    model   = OpenStudio::Model::Model.new

    file  = File.join(__dir__, "files/osms/in/5ZoneNoHVAC.osm")
    path  = OpenStudio::Path.new(file)
    model = OpenStudio::OSVersion::VersionTranslator.new.loadModel(path)
    expect(model.empty?).to be(false)
    model = model.get

    s30 = model.getSurfaceByName("Surface 30")
    expect(s30.empty?).to be(false)
    s30 = s30.get
    v30 = s30.vertices
    # v30.each {|x| puts x}
    #   30.86,  0.00, 3.80
    #   30.86, 10.86, 3.80
    #    0.00, 10.86, 3.80
    #    0.00,  0.00, 3.80
    gross = s30.grossArea
    expect(gross).to be_within(TOL).of(335.14)
    expect(s30.netArea).to be_within(TOL).of(gross)

    vec  = OpenStudio::Point3dVector.new
    vec << OpenStudio::Point3d.new(15.93, 4.93, 3.80)
    vec << OpenStudio::Point3d.new(15.93, 5.93, 3.80)
    vec << OpenStudio::Point3d.new(14.93, 5.93, 3.80)
    vec << OpenStudio::Point3d.new(14.93, 4.93, 3.80)
    sky  = OpenStudio::Model::SubSurface.new(vec, model)
    sky.setName("Skylight30")
    expect(sky.setSurface(s30)).to be(true)
    expect(sky.setSubSurfaceType("Skylight")).to be(true)
    expect(sky.netArea).to be_within(TOL).of(1)
    expect(sky.grossArea).to be_within(TOL).of(1)
    expect(sky.allowWindowPropertyFrameAndDivider).to be(true)
    expect(mod1.fits?(sky.vertices, v30)).to be(true)

    net  = gross
    net -= sky.grossArea
    srr  = s30.skylightToRoofRatio
    expect(srr).to be_within(TOL).of(0)
    expect(s30.netArea).to be_within(TOL).of(334.14)
    expect(srr).to be_within(0.001).of(0.003)                       # before F+D

    fd = OpenStudio::Model::WindowPropertyFrameAndDivider.new(model)
    width = 0.050
    expect(fd.setFrameWidth(width)).to be(true)   # 50mm (narrow) around glazing
    expect(fd.setFrameConductance(2.500)).to be(true)

    expect(sky.setWindowPropertyFrameAndDivider(fd)).to be(true)
    sky_w = sky.windowPropertyFrameAndDivider.get.frameWidth
    expect(sky_w).to be_within(0.001).of(width)
    expect(sky.netArea).to be_within(TOL).of(1)
    expect(sky.grossArea).to be_within(TOL).of(1)

    unless version < 340
      # sky.roughOpeningVertices.each { |vx| puts vx }              # clockwise!
      #   [14.88, 5.98, 3.8]
      #   [15.98, 5.98, 3.8]
      #   [15.98, 4.88, 3.8]
      #   [14.88, 4.88, 3.8]
      expect(mod1.fits?(sky.roughOpeningVertices, v30)).to be(false)
      expect(mod1.fits?(sky.roughOpeningVertices.reverse, v30)).to be(true)
      expect(mod1.logs.empty?).to be(true)

      expect(sky.roughOpeningArea).to be_within(TOL).of(1.21)
      net1  = gross
      net1 -= sky.roughOpeningArea
      expect(s30.netArea).to be_within(TOL).of(net1)             # F+D accepted!
      srr1  = s30.skylightToRoofRatio
      expect(srr1).to be_within(TOL).of(srr)     # yet not updated for skylights
      #
      #   https://github.com/NREL/OpenStudio/blob/
      #   e5c1e375db39b0f9b10512e9d6361cfec66308d6/src/model/Surface.cpp#L1547
      #
      #     vs
      #
      #   https://github.com/NREL/OpenStudio/blob/
      #   e5c1e375db39b0f9b10512e9d6361cfec66308d6/src/model/Surface.cpp#L1471
      #
      # In fact, when dealing with F+D objects, the updated SDK v340 WWR
      # calculations only consider subsurface types:
      #   - FixedWindow
      #   - OperableWindow
      #
      #   https://github.com/NREL/OpenStudio/blob/
      #   e5c1e375db39b0f9b10512e9d6361cfec66308d6/src/model/Surface.cpp#L1511
      #
      # ... bummer!
      sky_321 = mod1.offset(sky.vertices, width)
      expect(mod1.logs.empty?).to be(true)
      expect(sky_321.is_a?(Array)).to be(true)
      expect(sky_321.size).to eq(4)
      # sky_321.each { |x| puts x } # counterclockwise, reverse order
      # [14.88, 4.88, 3.8]
      # [15.98, 4.88, 3.8]
      # [15.98, 5.98, 3.8]
      # [14.88, 5.98, 3.8]
      sky_321_area = OpenStudio.getArea(sky_321)
      expect(sky_321_area.empty?).to be(false)
      expect(sky_321_area.get).to be_within(TOL).of(sky.roughOpeningArea)

      sky_300 = mod1.offset(sky.vertices, width, 300)    # oldest version tested
      expect(mod1.logs.empty?).to be(true)
      expect(sky_300.is_a?(Array)).to be(true)
      expect(sky_300.size).to eq(4)
      # sky_300.each { |vx| puts vx } # counterclockwise same order as originals
      # [15.98, 4.88, 3.8]
      # [15.98, 5.98, 3.8]
      # [14.88, 5.98, 3.8]
      # [14.88, 4.88, 3.8]
      sky_300_area = OpenStudio.getArea(sky_300)
      expect(sky_300_area.empty?).to be(false)
      expect(sky_300_area.get).to be_within(TOL).of(sky.roughOpeningArea)
    end

    # So for OpenStudio SDK v340+, one can rely on reported WWR to get a wall's
    # TRUE wall 'net area', as a means of determining whether added F+D objects
    # are valid or not. However, this is limited to operable or fixed windows:
    # F+D objects of glass doors are ignored in SDK v340-reported WWR. Opaque
    # doors are ignored altogether.
    #
    # When dealing with F+D added to skylights, the updated v340 'roof.netArea'
    # method indeed considers successfully-added F+D objects. Yet contrary to
    # reported WWR for walls, reported skylight-to-roof ratios (SRRs) do not!
    # And so other (bespoke) means are required, maybe resting on OSut's 'fits?'
    # & 'overlaps?' methods, to determine successful skylight F+D additions.
    #
    # Good luck with (exceptionally rare) glazed subsurface insertions in
    # exposed (e.g. cantilevered) floors.
    #
    # For earlier SDK versions, just NEVER rely on reported surface net area
    # or WWR/SRR when dealing with successful (or unsuccessful) F+D objects.
  end
end
