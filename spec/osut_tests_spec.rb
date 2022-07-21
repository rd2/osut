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

  it "can check scheduleCompactMinMax (from within class instances)" do
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

    spt = 22
    str = "Building HVAC Operation"
    cl1 = OpenStudio::Model::Schedule
    cl2 = OpenStudio::Model::ScheduleCompact
    m1 = "Invalid 'sched' arg #1 (OSut::scheduleCompactMinMax)"
    m2 = "'#{str}' #{cl1}? expecting #{cl2} (OSut::scheduleCompactMinMax)"

    sched = OpenStudio::Model::ScheduleCompact.new(model, spt)
    expect(sched.is_a?(OpenStudio::Model::ScheduleCompact)).to be(true)
    sched.setName("compact schedule")

    sch = model.getScheduleByName(str)
    expect(sch.empty?).to be(false)
    sch = sch.get

    # Valid case.
    minmax = cls1.scheduleCompactMinMax(sched)
    expect(minmax.is_a?(Hash)).to be(true)
    expect(minmax.key?(:min)).to be(true)
    expect(minmax.key?(:max)).to be(true)
    expect(minmax[:min]).to be_within(TOL).of(spt)
    expect(minmax[:min]).to be_within(TOL).of(spt)
    expect(cls1.status.zero?).to be(true)
    expect(cls1.logs.empty?).to be(true)

    # Invalid parameter.
    minmax = cls1.scheduleCompactMinMax(nil)
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
    minmax = cls1.scheduleCompactMinMax(model)
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
    minmax = cls1.scheduleCompactMinMax(sch)
    expect(minmax.is_a?(Hash)).to be(true)
    expect(minmax.key?(:min)).to be(true)
    expect(minmax.key?(:max)).to be(true)
    expect(minmax[:min].nil?).to be(true)
    expect(minmax[:max].nil?).to be(true)
    expect(cls1.debug?).to be(true)
    expect(cls1.logs.size).to eq(1)
    expect(cls1.logs.first[:message]).to eq(m2)

    expect(cls1.clean!).to eq(DBG)

  end

  it "can check construction thickness" do
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

  it "can check construction thickness (from within module instances)" do
    # Repeating the same exercice as above, yet with module instances.
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
      th = mod1.thickness(c)
      expect(th).to be_within(TOL).of(0) if id.include?("Air Wall")
      expect(th).to be_within(TOL).of(0) if id.include?("Double pane")
      next if id.include?("Air Wall")
      next if id.include?("Double pane")
      expect(th > 0).to be(true)
    end

    expect(mod1.status).to eq(ERR)
    expect(mod1.logs.size).to eq(2)
    msg = "holds non-StandardOpaqueMaterial(s) (OSut::thickness)"
    mod1.logs.each { |l| expect(l[:message].include?(msg)).to be(true) }

    expect(mod2.status).to eq(ERR)
    mod2.clean!
    expect(mod1.status.zero?).to eq(true)
    expect(mod1.logs.empty?).to be(true)

    model.getConstructions.each do |c|
      next if c.to_LayeredConstruction.empty?
      c = c.to_LayeredConstruction.get
      id = c.nameString
      next if id.include?("Air Wall")
      next if id.include?("Double pane")
      th = mod2.thickness(c)
      expect(th > 0).to be(true)
    end

    expect(mod2.status.zero?).to be(true)
    expect(mod2.logs.empty?).to be(true)
    expect(mod1.status.zero?).to eq(true)
    expect(mod1.logs.empty?).to be(true)
  end

  it "can check if a set holds a construction" do
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


  # it "can retrieve a surface default construction set" do
  #   translator = OpenStudio::OSVersion::VersionTranslator.new
  #   file = File.join(__dir__, "files/osms/in/5ZoneNoHVAC.osm")
  #   path = OpenStudio::Path.new(file)
  #   model = translator.loadModel(path)
  #   expect(model.empty?).to be(false)
  #   model = model.get
  #
  #   mod1.clean!
  #
  #   model.getSurfaces.each do |s|
  #     set = mod1.defaultConstructionSet(model, s)
  #     expect(set.nil?).to be(false)
  #     expect(mod1.status.zero?).to be(true)
  #     expect(mod1.logs.empty?).to be(true)
  #   end
  #
  #   translator = OpenStudio::OSVersion::VersionTranslator.new
  #   file = File.join(__dir__, "files/osms/in/seb.osm")
  #   path = OpenStudio::Path.new(file)
  #   model = translator.loadModel(path)
  #   expect(model.empty?).to be(false)
  #   model = model.get
  #
  #   mod1.clean!
  #
  #   model.getSurfaces.each do |s|
  #     set = mod1.defaultConstructionSet(model, s)
  #     expect(set.nil?).to be(true)
  #     expect(mod1.status).to eq(ERR)
  #     msg = "construction not defaulted (defaultConstructionSet)"
  #     mod1.logs.each {|l| expect(l[:message].include?(msg)) }
  #   end
  # end
end
