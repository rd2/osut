require "osut"

RSpec.describe OSut do
  TOL = 0.01
  DBG = OSut::DEBUG
  INF = OSut::INFO
  WRN = OSut::WARN
  ERR = OSut::ERR
  FTL = OSut::FATAL

  let(:cls1) { Class.new  { extend OSut } }
  let(:cls2) { Class.new  { extend OSut } }
  let(:mod1) { Module.new { extend OSut } }
  let(:mod2) { Module.new { extend OSut } }

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

  it "checks scheduleConstantMinMax (from within class instances)" do
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

  it "checks min/max heat/cool scheduled setpoints" do
    translator = OpenStudio::OSVersion::VersionTranslator.new
    file = File.join(__dir__, "files/osms/in/seb.osm")
    path = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model.empty?).to be(false)
    model = model.get

    expect(mod1.clean!).to eq(DBG)

    m1 = "OSut::maxHeatScheduledSetpoint"
    m2 = "OSut::minCoolScheduledSetpoint"
    z1 = "Level 0 Ceiling Plenum Zone"
    z2 = "Single zone"

    model.getThermalZones.each do |z|
      res = mod1.maxHeatScheduledSetpoint(z)
      expect(res.is_a?(Hash)).to be(true)
      expect(res.key?(:spt)).to be(true)
      expect(res.key?(:dual)).to be(true)
      expect(res[:spt].nil?).to be(true)            if z.nameString == z1
      expect(res[:spt]).to be_within(TOL).of(22.11) if z.nameString == z2
      expect(res[:dual]).to eq(false)               if z.nameString == z1
      expect(res[:dual]).to eq(true)                if z.nameString == z2
      expect(mod1.status.zero?).to be(true)

      res = mod1.minCoolScheduledSetpoint(z)
      expect(res.is_a?(Hash)).to be(true)
      expect(res.key?(:spt)).to be(true)
      expect(res.key?(:dual)).to be(true)
      expect(res[:spt].nil?).to be(true)            if z.nameString == z1
      expect(res[:spt]).to be_within(TOL).of(22.78) if z.nameString == z2
      expect(res[:dual]).to eq(false)               if z.nameString == z1
      expect(res[:dual]).to eq(true)                if z.nameString == z2
      expect(mod1.status.zero?).to be(true)
    end

    res = mod1.maxHeatScheduledSetpoint(nil)                      # bad argument
    expect(res.is_a?(Hash)).to be(true)
    expect(res.key?(:spt)).to be(true)
    expect(res.key?(:dual)).to be(true)
    expect(res[:spt].nil?).to be(true)
    expect(res[:dual]).to eq(false)
    expect(mod1.debug?).to be(true)
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq("Invalid 'zone' arg #1 (#{m1})")
    expect(mod1.clean!).to eq(DBG)

    res = mod1.minCoolScheduledSetpoint(nil)                      # bad argument
    expect(res.is_a?(Hash)).to be(true)
    expect(res.key?(:spt)).to be(true)
    expect(res.key?(:dual)).to be(true)
    expect(res[:spt].nil?).to be(true)
    expect(res[:dual]).to eq(false)
    expect(mod1.debug?).to be(true)
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq("Invalid 'zone' arg #1 (#{m2})")
    expect(mod1.clean!).to eq(DBG)

    res = mod1.maxHeatScheduledSetpoint(model)                    # bad argument
    expect(res.is_a?(Hash)).to be(true)
    expect(res.key?(:spt)).to be(true)
    expect(res.key?(:dual)).to be(true)
    expect(res[:spt].nil?).to be(true)
    expect(res[:dual]).to eq(false)
    expect(mod1.debug?).to be(true)
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq("Invalid 'zone' arg #1 (#{m1})")
    expect(mod1.clean!).to eq(DBG)

    res = mod1.minCoolScheduledSetpoint(model)                    # bad argument
    expect(res.is_a?(Hash)).to be(true)
    expect(res.key?(:spt)).to be(true)
    expect(res.key?(:dual)).to be(true)
    expect(res[:spt].nil?).to be(true)
    expect(res[:dual]).to eq(false)
    expect(mod1.debug?).to be(true)
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq("Invalid 'zone' arg #1 (#{m2})")
    expect(mod1.clean!).to eq(DBG)
  end

  it "checks if zones have heating/cooling temperature setpoints" do
    translator = OpenStudio::OSVersion::VersionTranslator.new
    file = File.join(__dir__, "files/osms/in/seb.osm")
    path = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model.empty?).to be(false)
    model = model.get

    m1 = "OSut::heatingTemperatureSetpoints?"
    m2 = "OSut::coolingTemperatureSetpoints?"

    expect(mod1.clean!).to eq(DBG)
    expect(mod1.heatingTemperatureSetpoints?(model)).to be(true)
    expect(mod1.status.zero?).to be(true)

    expect(mod1.coolingTemperatureSetpoints?(model)).to be(true)
    expect(mod1.status.zero?).to be(true)

    expect(mod1.heatingTemperatureSetpoints?(nil)).to be(false)   # bad argument
    expect(mod1.debug?).to be(true)
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq("Invalid 'model' arg #1 (#{m1})")

    expect(mod1.clean!).to eq(DBG)
    expect(mod1.coolingTemperatureSetpoints?(nil)).to be(false)   # bad argument
    expect(mod1.debug?).to be(true)
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq("Invalid 'model' arg #1 (#{m2})")
  end

  it "checks for HVAC air loops" do
    translator = OpenStudio::OSVersion::VersionTranslator.new
    file = File.join(__dir__, "files/osms/in/seb.osm")
    path = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model.empty?).to be(false)
    model = model.get

    m = "OSut::airLoopsHVAC?"

    expect(mod1.clean!).to eq(DBG)
    expect(mod1.airLoopsHVAC?(model)).to be(true)
    expect(mod1.status.zero?).to be(true)

    expect(mod1.airLoopsHVAC?(nil)).to be(false)
    expect(mod1.debug?).to be(true)
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq("Invalid 'model' arg #1 (#{m})")

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
    expect(mod1.logs.first[:message]).to eq("Invalid 'model' arg #1 (#{m})")
  end

  it "checks for plenums" do
    translator = OpenStudio::OSVersion::VersionTranslator.new
    file = File.join(__dir__, "files/osms/in/seb.osm")
    path = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model.empty?).to be(false)
    model = model.get

    m  = "OSut::plenum?"
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
      expect(mod1.plenum?(space, loops, setpoints)).to be(true) if id == sp
      expect(mod1.plenum?(space, loops, setpoints)).to be(false) unless id == sp
    end

    expect(mod1.status.zero?).to be(true)

    expect(mod1.plenum?(nil, loops, setpoints)).to be(false)
    expect(mod1.debug?).to be(true)
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq("Invalid 'space' arg #1 (#{m})")

    translator = OpenStudio::OSVersion::VersionTranslator.new
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

  it "checks model transformation" do
    translator = OpenStudio::OSVersion::VersionTranslator.new
    file = File.join(__dir__, "files/osms/in/seb.osm")
    path = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model.empty?).to be(false)
    model = model.get

    m = "OSut::transforms"
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
    expect(mod1.logs.first[:message]).to eq("Invalid 'group' arg #2 (#{m})")
  end

  it "checks construction thickness" do
    translator = OpenStudio::OSVersion::VersionTranslator.new
    file = File.join(__dir__, "files/osms/in/seb.osm")
    path = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model.empty?).to be(false)
    model = model.get

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
    msg = "holds non-StandardOpaqueMaterial(s) (OSut::thickness)"
    cls1.logs.each { |l| expect(l[:message].include?(msg)).to be(true) }

    # OSut, and by extension OSlg, are intended to be accessed "globally"
    # once instantiated within a class or module. Here, class instance cls2
    # accesses the same OSut module methods as cls1.

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
  end


  it "retrieves a surface default construction set" do
    translator = OpenStudio::OSVersion::VersionTranslator.new
    file = File.join(__dir__, "files/osms/in/5ZoneNoHVAC.osm")
    path = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model.empty?).to be(false)
    model = model.get

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
      msg = "construction not defaulted (defaultConstructionSet)"
      mod1.logs.each {|l| expect(l[:message].include?(msg)) }
    end
  end
end
