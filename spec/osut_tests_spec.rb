require "osut"

RSpec.describe OSut do
  TOL  = OSut::TOL
  DBG  = OSut::DEBUG
  INF  = OSut::INFO
  WRN  = OSut::WARN
  ERR  = OSut::ERR
  FTL  = OSut::FATAL
  HEAD = OSut::HEAD
  SILL = OSut::SILL

  let(:cls1) { Class.new  { extend OSut } }
  let(:cls2) { Class.new  { extend OSut } }
  let(:mod1) { Module.new { extend OSut } }

  it "checks generated constructions" do
    expect(cls1.level).to eq(INF)
    expect(cls1.reset(DBG)).to eq(DBG)
    expect(cls1.level).to eq(DBG)
    expect(cls1.clean!).to eq(DBG)

    model          = OpenStudio::Model::Model.new
    specs          = {}
    specs[:type  ] = :wall
    specs[:uo    ] = 0.210 # NECB2017
    surface        = cls1.genConstruction(model, specs)
    expect(surface.nil?).to be(false)
    expect(cls1.status.zero?).to be(true)
    expect(surface.is_a?(OpenStudio::Model::LayeredConstruction)).to be(true)
    expect(surface.layers.size).to eq(4)
    u = 1 / cls1.rsi(surface, 0.140)
    expect(u).to be_within(TOL).of(specs[:uo])

    specs[:type  ] = :roof
    specs[:uo    ] = 1 / 5.46 # CCQ I1
    surface        = cls1::genConstruction(model, specs)
    expect(surface.nil?).to be(false)
    expect(cls1.status.zero?).to be(true)
    expect(surface.is_a?(OpenStudio::Model::LayeredConstruction)).to be(true)
    expect(surface.layers.size).to eq(4)
    u = 1 / cls1::rsi(surface, 0.140)
    expect(u).to be_within(TOL).of(specs[:uo])

    specs          = {}
    specs[:type  ] = :roof
    specs[:frame ] = :medium
    specs[:finish] = :heavy
    specs[:uo    ] = 1 / 5.46 # CCQ I1
    surface        = cls1::genConstruction(model, specs)
    expect(surface.nil?).to be(false)
    expect(cls1.status.zero?).to be(true)
    expect(surface.is_a?(OpenStudio::Model::LayeredConstruction)).to be(true)
    expect(surface.layers.size).to eq(4)
    u = 1 / cls1::rsi(surface, 0.140)
    expect(u).to be_within(TOL).of(specs[:uo])

    specs          = {}
    specs[:type  ] = :floor
    specs[:frame ] = :medium
    specs[:uo    ] = 1 / 5.46 # CCQ I1
    surface        = cls1::genConstruction(model, specs)
    expect(surface.nil?).to be(false)
    expect(cls1.status.zero?).to be(true)
    expect(surface.is_a?(OpenStudio::Model::LayeredConstruction)).to be(true)
    expect(surface.layers.size).to eq(4)
    u = 1 / cls1::rsi(surface, 0.190)
    expect(u).to be_within(TOL).of(specs[:uo])

    specs          = {}
    specs[:type  ] = :slab
    specs[:frame ] = :none
    specs[:finish] = :none
    surface        = cls1::genConstruction(model, specs)
    expect(surface.nil?).to be(false)
    expect(cls1.status.zero?).to be(true)
    expect(surface.is_a?(OpenStudio::Model::LayeredConstruction)).to be(true)
    expect(surface.layers.size).to eq(2)

    specs          = {}
    specs[:type  ] = :slab
    specs[:finish] = :none
    specs[:uo    ] = 0.379 # NECB2020, ZC8
    surface        = cls1::genConstruction(model, specs)
    expect(surface.nil?).to be(false)
    expect(cls1.status.zero?).to be(true)
    expect(surface.is_a?(OpenStudio::Model::LayeredConstruction)).to be(true)
    expect(surface.layers.size).to eq(3)
    u = 1 / cls1::rsi(surface, 0.160)
    expect(u).to be_within(TOL).of(specs[:uo])

    specs          = {}
    specs[:type  ] = :slab
    specs[:uo    ] = 0.379 # NECB2020, ZC8
    surface        = cls1::genConstruction(model, specs)
    expect(surface.nil?).to be(false)
    expect(cls1.status.zero?).to be(true)
    expect(surface.is_a?(OpenStudio::Model::LayeredConstruction)).to be(true)
    expect(surface.layers.size).to eq(4)
    u = 1 / cls1::rsi(surface, 0.160)
    expect(u).to be_within(TOL).of(specs[:uo])

    specs          = {}
    specs[:type  ] = :basement
    specs[:clad  ] = :heavy
    specs[:uo    ] = 1 / 2.64 # CCQ I1
    surface        = cls1::genConstruction(model, specs)
    expect(surface.nil?).to be(false)
    expect(cls1.status.zero?).to be(true)
    expect(surface.is_a?(OpenStudio::Model::LayeredConstruction)).to be(true)
    expect(surface.layers.size).to eq(3)
    u = 1 / cls1::rsi(surface, 0.120)
    expect(u).to be_within(TOL).of(specs[:uo])

    specs          = {}
    specs[:type  ] = :basement
    specs[:clad  ] = :none
    specs[:finish] = :light
    specs[:uo    ] = 1 / 2.64 # CCQ I1
    surface        = cls1::genConstruction(model, specs)
    expect(surface.nil?).to be(false)
    expect(cls1.status.zero?).to be(true)
    expect(surface.is_a?(OpenStudio::Model::LayeredConstruction)).to be(true)
    expect(surface.layers.size).to eq(3)
    u = 1 / cls1::rsi(surface, 0.120)
    expect(u).to be_within(TOL).of(specs[:uo])

    specs          = {}
    specs[:type  ] = :door
    specs[:frame ] = :medium # ... should be ignored
    specs[:uo    ] = 1.8
    surface        = cls1::genConstruction(model, specs)
    expect(surface.nil?).to be(false)
    expect(cls1.status.zero?).to be(true)
    expect(surface.is_a?(OpenStudio::Model::LayeredConstruction)).to be(true)
    expect(surface.layers.size).to eq(1)
    u = 1 / cls1::rsi(surface, 0.150)
    expect(u).to be_within(TOL).of(specs[:uo])

    specs          = {}
    specs[:type  ] = :door
    specs[:uo    ] = 0.9 # CCQ I1
    surface        = cls1::genConstruction(model, specs)
    expect(surface.nil?).to be(false)
    expect(cls1.status.zero?).to be(true)
    expect(surface.is_a?(OpenStudio::Model::LayeredConstruction)).to be(true)
    expect(surface.layers.size).to eq(1)
    u = 1 / cls1::rsi(surface, 0.150)
    expect(u).to be_within(TOL).of(specs[:uo])

    specs          = {}
    specs[:type  ] = :window
    specs[:uo    ] = 2.0
    surface        = cls1::genConstruction(model, specs)
    expect(surface.nil?).to be(false)
    expect(cls1.status.zero?).to be(true)
    expect(surface.is_a?(OpenStudio::Model::LayeredConstruction)).to be(true)
    expect(surface.layers.size).to eq(1)
    u = 1 / cls1::rsi(surface) # not necessary to specify film
    expect(u).to be_within(TOL).of(specs[:uo])

    specs          = {}
    specs[:type  ] = :window
    specs[:uo    ] = 0.9 # CCQ I1
    surface        = cls1::genConstruction(model, specs)
    expect(surface.nil?).to be(false)
    expect(cls1.status.zero?).to be(true)
    expect(surface.is_a?(OpenStudio::Model::LayeredConstruction)).to be(true)
    expect(surface.layers.size).to eq(1)
    u = 1 / cls1::rsi(surface) # not necessary to specify film
    expect(u).to be_within(TOL).of(specs[:uo])

    specs          = {}
    specs[:type  ] = :skylight
    specs[:uo    ] = 2.8 # CCQ I1
    surface        = cls1::genConstruction(model, specs)
    expect(surface.nil?).to be(false)
    expect(cls1.status.zero?).to be(true)
    expect(surface.is_a?(OpenStudio::Model::LayeredConstruction)).to be(true)
    expect(surface.layers.size).to eq(1)
    u = 1 / cls1::rsi(surface) # not necessary to specify film
    expect(u).to be_within(TOL).of(specs[:uo])
  end

  it "checks roller shades" do
    expect(mod1.reset(DBG)).to eq(DBG)
    expect(mod1.level).to eq(DBG)
    expect(mod1.clean!).to eq(DBG)

    translator = OpenStudio::OSVersion::VersionTranslator.new
    v = OpenStudio.openStudioVersion.split(".").join.to_i
    file = File.join(__dir__, "files/osms/out/seb_ext4.osm")
    path = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model.empty?).to be(false)
    model = model.get
    spaces = model.getSpaces

    slanted = mod1.facets(spaces, "Outdoors", "RoofCeiling", [:top, :north])
    expect(slanted.size).to eq(1)
    slanted = slanted.first
    expect(slanted.nameString).to eq("Openarea slanted roof")
    skylights = slanted.subSurfaces

    tilted = mod1.facets(spaces, "Outdoors", "Wall", [:bottom])
    expect(tilted.size).to eq(1)
    tilted = tilted.first
    expect(tilted.nameString).to eq("Openarea tilted wall")
    windows = tilted.subSurfaces

    # 2x control groups:
    #   - 3x windows as a single control group
    #   - 3x skylight as another single control group
    skies = OpenStudio::Model::SubSurfaceVector.new
    wins  = OpenStudio::Model::SubSurfaceVector.new
    skylights.each { |sub| skies << sub }
    windows.each   { |sub| wins  << sub }

    if v < 321
      expect(mod1.genShade(model, skies)).to be(false)
    else
      expect(mod1.genShade(model, skies)).to be(true)
      expect(mod1.genShade(model, wins)).to be(true)
      ctls = model.getShadingControls
      expect(ctls.size).to eq(2)

      ctls.each do |ctl|
        expect(ctl.shadingType).to eq("InteriorShade")
        type = "OnIfHighOutdoorAirTempAndHighSolarOnWindow"
        expect(ctl.shadingControlType).to eq(type)
        expect(ctl.isControlTypeValueNeedingSetpoint1).to be(true)
        expect(ctl.isControlTypeValueNeedingSetpoint2).to be(true)
        expect(ctl.isControlTypeValueAllowingSchedule).to be(true)
        expect(ctl.isControlTypeValueRequiringSchedule).to be(false)
        spt1 = ctl.setpoint
        spt2 = ctl.setpoint2
        expect(spt1.empty?).to be(false)
        expect(spt2.empty?).to be(false)
        spt1 = spt1.get
        spt2 = spt2.get
        expect(spt1).to be_within(TOL).of(18)
        expect(spt2).to be_within(TOL).of(100)
        expect(ctl.multipleSurfaceControlType).to eq("Group")

        ctl.subSurfaces.each do |sub|
          surface = sub.surface
          expect(surface.empty?).to be(false)
          surface = surface.get
          ok = surface == slanted || surface == tilted
          expect(ok).to be(true)
        end
      end
    end

    file = File.join(__dir__, "files/osms/out/seb_ext5.osm")
    model.save(file, true)
  end

  it "checks internal mass" do
    expect(mod1.clean!).to eq(DBG)

    ratios   = {entrance: 0.1, lobby: 0.3, meeting: 1.0}
    model    = OpenStudio::Model::Model.new
    entrance = OpenStudio::Model::Space.new(model)
    lobby    = OpenStudio::Model::Space.new(model)
    meeting  = OpenStudio::Model::Space.new(model)
    offices  = OpenStudio::Model::Space.new(model)

    entrance.setName("Entrance")
    lobby.setName("Lobby")
    meeting.setName("Meeting")
    offices.setName("Offices")

    model.getSpaces.each do |space|
      name  = space.nameString.downcase.to_sym
      ratio = nil
      ratio = ratios[name] if ratios.keys.include?(name)
      ok    = mod1.genMass(model, [space], ratio) unless ratio.nil?
      ok    = mod1.genMass(model, [space])            if ratio.nil?
      expect(ok).to be(true)
      expect(mod1.status.zero?).to be(true)
    end

    construction = nil
    material = nil

    model.getInternalMasss.each do |m|
      d = m.internalMassDefinition
      expect(d.designLevelCalculationMethod).to eq("SurfaceArea/Area")
      ratio = d.surfaceAreaperSpaceFloorArea
      expect(ratio.empty?).to be(false)
      ratio = ratio.get

      case ratio
      when 0.1
        expect(d.nameString).to eq("OSut|InternalMassDefinition|0.10")
        expect(m.nameString.downcase.include?("entrance")).to be(true)
      when 0.3
        expect(d.nameString).to eq("OSut|InternalMassDefinition|0.30")
        expect(m.nameString.downcase.include?("lobby")).to be(true)
      when 1.0
        expect(d.nameString).to eq("OSut|InternalMassDefinition|1.00")
        expect(m.nameString.downcase.include?("meeting")).to be(true)
      else
        expect(d.nameString).to eq("OSut|InternalMassDefinition|2.00")
        expect(ratio).to eq(2.0)
      end

      c = d.construction
      expect(c.empty?).to be(false)
      c = c.get.to_Construction
      expect(c.empty?).to be(false)
      c = c.get
      construction = c if construction.nil?
      expect(construction).to eq(c)
      expect(c.nameString).to eq("OSut|MASS|Construction")
      expect(c.numLayers).to eq(1)
      m = c.layers.first
      material = m if material.nil?
      expect(material).to eq(m)
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
    mdl = OpenStudio::Model::Model.new
    version = mdl.getVersion.versionIdentifier.split('.').map(&:to_i)
    v = version.join.to_i
    translator = OpenStudio::OSVersion::VersionTranslator.new

    if v < 350 # 5ZoneNoHVAC holds 1x OS:Material:AirWall, deprecated > 3.4.0
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
  end

  it "retrieves a surface default construction set" do
    mdl = OpenStudio::Model::Model.new
    version = mdl.getVersion.versionIdentifier.split('.').map(&:to_i)
    v = version.join.to_i

    translator = OpenStudio::OSVersion::VersionTranslator.new

    if v < 350 # 5ZoneNoHVAC holds 1x OS:Material:AirWall, deprecated > 3.4.0
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

        mod1.logs.each { |l| expect(l[:message].include?(m)) }
      end
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

    # PlanarSurface class method 'filmResistance' reports standard interior or
    # exterior air film resistances (ref: ASHRAE Fundamentals), e.g.:
    types = {}
    types["StillAir_HorizontalSurface_HeatFlowsUpward"  ] = 0.107
    types["StillAir_45DegreeSurface_HeatFlowsUpward"    ] = 0.109
    types["StillAir_VerticalSurface"                    ] = 0.120
    types["StillAir_45DegreeSurface_HeatFlowsDownward"  ] = 0.134
    types["StillAir_HorizontalSurface_HeatFlowsDownward"] = 0.162
    types["MovingAir_15mph"                             ] = 0.030
    types["MovingAir_7p5mph"                            ] = 0.044
    #   https://github.com/NREL/OpenStudio/blob/
    #   1c6fe48c49987c16e95e90ee3bd088ad0649ab9c/src/model/
    #   PlanarSurface.cpp#L854

    OpenStudio::Model::FilmResistanceType.getValues.each do |i|
      t1 = OpenStudio::Model::FilmResistanceType.new(i)
      t2 = OpenStudio::Model::FilmResistanceType.new(types.keys.at(i))
      r  = OpenStudio::Model::PlanarSurface.filmResistance(t1)
      expect(t1).to eq(t2)
      expect(r).to be_within(0.001).of(types.values.at(i))
      next if i > 4

      # PlanarSurface class method 'stillAirFilmResistance' offers a
      # tilt-dependent interior air film resistance, e.g.:
      deg = i * 45
      rad = deg * Math::PI/180
      rsi = OpenStudio::Model::PlanarSurface.stillAirFilmResistance(rad)
      # puts "#{i}: #{deg}: #{r}: #{rsi}"
      # 0:   0: 0.107: 0.106
      # 1:  45: 0.109: 0.109 # ... OK
      # 2:  90: 0.120: 0.120 # ... OK
      # 3: 135: 0.134: 0.137
      # 4: 180: 0.162: 0.160
      next if deg < 45 || deg > 90

      expect(rsi).to be_within(0.001).of(r)
      # The method is used for (opaque) Surfaces. The correlation/regression
      # isn't perfect, yet appears fairly reliable for intermediate angles
      # between ~0° and 90°.
      #   https://github.com/NREL/OpenStudio/blob/
      #   1c6fe48c49987c16e95e90ee3bd088ad0649ab9c/src/model/
      #   PlanarSurface.cpp#L878
    end
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

  it "checks scheduleRulesetMinMax (from within class instances)" do
    expect(cls1.level).to eq(DBG)
    expect(cls1.clean!).to eq(DBG)

    translator = OpenStudio::OSVersion::VersionTranslator.new
    file = File.join(__dir__, "files/osms/in/seb.osm")
    path = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model.empty?).to be(false)
    model = model.get

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
    mdl = OpenStudio::Model::Model.new
    version = mdl.getVersion.versionIdentifier.split('.').map(&:to_i)
    v = version.join.to_i

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


    if v < 350 # 5ZoneNoHVAC holds 1x OS:Material:AirWall, deprecated > 3.4.0
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
  end

  it "checks for plenums" do
    mdl = OpenStudio::Model::Model.new
    version = mdl.getVersion.versionIdentifier.split('.').map(&:to_i)
    v = version.join.to_i

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


    if v < 350 # 5ZoneNoHVAC holds 1x OS:Material:AirWall, deprecated > 3.4.0
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
    mdl = OpenStudio::Model::Model.new
    version = mdl.getVersion.versionIdentifier.split('.').map(&:to_i)
    v = version.join.to_i

    translator = OpenStudio::OSVersion::VersionTranslator.new
    file = File.join(__dir__, "files/osms/in/seb.osm")
    path = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model.empty?).to be(false)
    model = model.get

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
    expect(mod1.reset(DBG)).to eq(DBG)
    expect(mod1.level).to eq(DBG)
    expect(mod1.clean!).to eq(DBG)

    mdl = OpenStudio::Model::Model.new
    version = mdl.getVersion.versionIdentifier.split('.').map(&:to_i)
    v = version.join.to_i

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

    if v < 350 # 5ZoneNoHVAC holds 1x OS:Material:AirWall, deprecated > 3.4.0
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
  end

  it "checks flattened 3D points" do
    expect(mod1.reset(DBG)).to eq(DBG)
    expect(mod1.level).to eq(DBG)
    expect(mod1.clean!).to eq(DBG)

    translator = OpenStudio::OSVersion::VersionTranslator.new
    file  = File.join(__dir__, "files/osms/in/seb.osm")
    path  = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    model = model.get

    cl1 = OpenStudio::Model::Model
    cl2 = OpenStudio::Point3dVector
    cl3 = OpenStudio::Point3d
    cl4 = NilClass
    m   = "OSut::flatten"
    m1  = "'points' #{cl4}?"
    m2  = "'points' #{cl1}?"

    model.getSurfaces.each do |s|
      next unless s.isPartOfEnvelope
      next unless s.surfaceType == "RoofCeiling"
      flat = mod1.flatten(s)
      expect(flat.is_a?(cl2)).to be(true)
      expect(mod1.xyz?(flat, :z, 0)).to be(true)
      expect(s.vertices.first.x).to be_within(TOL).of(flat.first.x)
      expect(s.vertices.first.y).to be_within(TOL).of(flat.first.y)
    end

    expect(mod1.status.zero?).to be(true)
    flat = mod1.flatten(nil)
    expect(flat.is_a?(cl2)).to be(true)
    expect(flat.empty?).to be(true)
    expect(mod1.debug?).to be(true)
    expect(mod1.logs.size).to be(1)
    expect(mod1.logs.first[:message].include?(m1)).to be(true)

    expect(mod1.clean!).to eq(DBG)
    flat = mod1.flatten(model)
    expect(flat.is_a?(cl2)).to be(true)
    expect(flat.empty?).to be(true)
    expect(mod1.debug?).to be(true)
    expect(mod1.logs.size).to be(1)
    expect(mod1.logs.first[:message].include?(m2)).to be(true)
  end

  it "checks surface fits? & overlaps?" do
    expect(mod1.reset(DBG)).to eq(DBG)
    expect(mod1.level).to eq(DBG)
    expect(mod1.clean!).to eq(DBG)

    # Note: As of OpenStudio v340, the following method is available as an
    # all-in-one solution to check if a polygon fits within another polygon.
    #
    # answer = OpenStudio.polygonInPolygon(aligned_door, aligned_wall, TOL)
    #
    # As with other Boost-based methods, it requires 'aligned' surfaces
    # (using OpenStudio Transformation' alignFace method), and set in a
    # clockwise sequence. OSut sticks to fits? as it executes these steps
    # behind the scenes, and remains consistent for pre-v340 implementations.

    model = OpenStudio::Model::Model.new

    # 10m x 10m parent vertical (wall) surface.
    vec = OpenStudio::Point3dVector.new
    vec << OpenStudio::Point3d.new(  0,  0, 10)
    vec << OpenStudio::Point3d.new(  0,  0,  0)
    vec << OpenStudio::Point3d.new( 10,  0,  0)
    vec << OpenStudio::Point3d.new( 10,  0, 10)
    wall = OpenStudio::Model::Surface.new(vec, model)

    # 1m x 2m corner door (with 2x edges along wall edges)
    vec = OpenStudio::Point3dVector.new
    vec << OpenStudio::Point3d.new(  0,  0,  2)
    vec << OpenStudio::Point3d.new(  0,  0,  0)
    vec << OpenStudio::Point3d.new(  1,  0,  0)
    vec << OpenStudio::Point3d.new(  1,  0,  2)
    door1 = OpenStudio::Model::SubSurface.new(vec, model)

    expect(mod1.fits?(door1, wall)).to be(true)
    expect(mod1.status.zero?).to be(true)
    expect(mod1.overlaps?(door1, wall)).to be(true)
    expect(mod1.status.zero?).to be(true)

    # Order of arguments matter.
    expect(mod1.fits?(wall, door1)).to be(false)
    expect(mod1.overlaps?(wall, door1)).to be(true)
    expect(mod1.status.zero?).to be(true)

    # Another 1m x 2m corner door, yet entirely beyond the wall surface.
    vec = OpenStudio::Point3dVector.new
    vec << OpenStudio::Point3d.new( 16,  0,  2)
    vec << OpenStudio::Point3d.new( 16,  0,  0)
    vec << OpenStudio::Point3d.new( 17,  0,  0)
    vec << OpenStudio::Point3d.new( 17,  0,  2)
    door2 = OpenStudio::Model::SubSurface.new(vec, model)

    # Door2 fits?, overlaps?
    expect(mod1.fits?(door2, wall)).to be(false)
    expect(mod1.overlaps?(door2, wall)).to be(false)
    expect(mod1.status.zero?).to be(true)

    # Order of arguments doesn't matter.
    expect(mod1.fits?(wall, door2)).to be(false)
    expect(mod1.overlaps?(wall, door2)).to be(false)
    expect(mod1.status.zero?).to be(true)

    # Top-right corner 2m x 2m window, overlapping top-right corner of wall.
    vec = OpenStudio::Point3dVector.new
    vec << OpenStudio::Point3d.new(  9,  0, 11)
    vec << OpenStudio::Point3d.new(  9,  0,  9)
    vec << OpenStudio::Point3d.new( 11,  0,  9)
    vec << OpenStudio::Point3d.new( 11,  0, 11)
    window = OpenStudio::Model::SubSurface.new(vec, model)

    # Window fits?, overlaps?
    expect(mod1.fits?(window, wall)).to be(false)
    expect(mod1.overlaps?(window, wall)).to be(true)
    expect(mod1.status.zero?).to be(true)

    expect(mod1.fits?(wall, window)).to be(false)
    expect(mod1.overlaps?(wall, window)).to be(true)
    expect(mod1.status.zero?).to be(true)

    # A glazed surface, entirely encompassing the wall.
    vec = OpenStudio::Point3dVector.new
    vec << OpenStudio::Point3d.new(  0,  0, 10)
    vec << OpenStudio::Point3d.new(  0,  0,  0)
    vec << OpenStudio::Point3d.new( 10,  0,  0)
    vec << OpenStudio::Point3d.new( 10,  0, 10)
    glazing = OpenStudio::Model::SubSurface.new(vec, model)

    # Glazing fits?, overlaps?
    expect(mod1.fits?(glazing, wall)).to be(true)
    expect(mod1.overlaps?(glazing, wall)).to be(true)
    expect(mod1.status.zero?).to be(true)

    expect(mod1.fits?(wall, glazing)).to be(true)
    expect(mod1.overlaps?(wall, glazing)).to be(true)
    expect(mod1.status.zero?).to be(true)
  end

  it "checks triangulation" do
    expect(mod1.reset(DBG)).to eq(DBG)
    expect(mod1.level).to eq(DBG)
    expect(mod1.clean!).to eq(DBG)

    holes = OpenStudio::Point3dVectorVector.new

    # Regular polygon, counterclockwise yet not UpperLeftCorner (ULC).
    vtx  = OpenStudio::Point3dVector.new
    vtx << OpenStudio::Point3d.new(20, 0, 10)
    vtx << OpenStudio::Point3d.new( 0, 0, 10)
    vtx << OpenStudio::Point3d.new( 0, 0,  0)

    # Polygons must be 'aligned', and in a clockwise sequence.
    t       = OpenStudio::Transformation.alignFace(vtx)
    a_vtx   = (t.inverse * vtx).reverse
    results = OpenStudio.computeTriangulation(a_vtx, holes)
    expect(results.size).to eq(1)
    # puts results.first.reverse # ... results == initial triangle
    # [20, 10, 0]
    # [ 0, 10, 0]
    # [ 0,  0, 0]

    vtx << OpenStudio::Point3d.new(20, 0,  0)
    t       = OpenStudio::Transformation.alignFace(vtx)
    a_vtx   = (t.inverse * vtx).reverse
    results = OpenStudio.computeTriangulation(a_vtx, holes)
    expect(results.size).to eq(2)
    # results.each { |result| puts result }
    # [ 0, 10, 0]
    # [20, 10, 0]
    # [20,  0, 0]
    #
    # [ 0,  0, 0]
    # [ 0, 10, 0]
    # [20,  0, 0]
  end

  it "checks surface width & height" do
    expect(mod1.reset(DBG)).to eq(DBG)
    expect(mod1.level).to eq(DBG)
    expect(mod1.clean!).to eq(DBG)

    translator = OpenStudio::OSVersion::VersionTranslator.new
    file = File.join(__dir__, "files/osms/out/seb_ext2.osm")
    path = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model.empty?).to be(false)
    model = model.get

    tilted = model.getSurfaceByName("Openarea tilted wall")
    expect(tilted.empty?).to be(false)
    tilted = tilted.get
    w1 = mod1.width(tilted)
    h1 = mod1.height(tilted)
    expect(w1).to be_within(TOL).of(5.89)
    expect(h1).to be_within(TOL).of(3.09)

    left = model.getSurfaceByName("Openarea left side wall")
    expect(left.empty?).to be(false)
    left = left.get
    w2 = mod1.width(left)
    h2 = mod1.height(left)
    expect(w2).to be_within(TOL).of(2.24)
    expect(h2).to be_within(TOL).of(3.35)

    right = model.getSurfaceByName("Openarea right side wall")
    expect(right.empty?).to be(false)
    right = right.get
    w3 = mod1.width(right)
    h3 = mod1.height(right)
    expect(w3).to be_within(TOL).of(w2)
    expect(h3).to be_within(TOL).of(h2)

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # What if wall vertex sequences were no longer ULC (e.g. URC)?
    vec  = OpenStudio::Point3dVector.new
    vec << tilted.vertices[3]
    vec << tilted.vertices[0]
    vec << tilted.vertices[1]
    vec << tilted.vertices[2]
    expect(tilted.setVertices(vec)).to be(true)
    expect(mod1.width(tilted)).to be_within(TOL).of(w1)  # same result
    expect(mod1.height(tilted)).to be_within(TOL).of(h1) # same result

    file = File.join(__dir__, "files/osms/out/seb_ext4.osm")
    model.save(file, true)
  end

  it "checks line segments, triads & orientation" do
    expect(mod1.reset(DBG)).to eq(DBG)
    expect(mod1.level).to eq(DBG)
    expect(mod1.clean!).to eq(DBG)

    # Regular polygon, counterclockwise yet not UpperLeftCorner (ULC).
    vtx  = OpenStudio::Point3dVector.new
    vtx << OpenStudio::Point3d.new(20, 0, 10)
    vtx << OpenStudio::Point3d.new( 0, 0, 10)
    vtx << OpenStudio::Point3d.new( 0, 0,  0)

    segments = mod1.getSegments(vtx)
    expect(segments.is_a?(OpenStudio::Point3dVectorVector)).to be(true)
    expect(segments.size).to eq(3)

    segments.each_with_index do |segment, i|
      expect(mod1.yy?(segment.first, segment.last)).to be(false)
      expect(mod1.yy?(segment.first, segment.last, false)).to be(false)

      case i
      when 0
        expect(mod1.xx?(segment.first, segment.last)).to be(true)
        expect(mod1.xx?(segment.first, segment.last, false)).to be(true)
        expect(mod1.zz?(segment.first, segment.last)).to be(false)
        expect(mod1.zz?(segment.first, segment.last, false)).to be(false)
      when 1
        expect(mod1.zz?(segment.first, segment.last)).to be(true)
        expect(mod1.zz?(segment.first, segment.last, false)).to be(true)
        expect(mod1.xx?(segment.first, segment.last)).to be(false)
        expect(mod1.xx?(segment.first, segment.last, false)).to be(false)
      else
        expect(mod1.xx?(segment.first, segment.last)).to be(false)
        expect(mod1.xx?(segment.first, segment.last, false)).to be(true)
        expect(mod1.zz?(segment.first, segment.last)).to be(false)
        expect(mod1.zz?(segment.first, segment.last, false)).to be(true)
      end
    end

    # Retrieve polygon 'triads' (3x consecutive points) and qualify each as
    # describing an acute, right or obtuse angle. As the considered polygons
    # are either triangles or convex quadrilaterals, the number of returned
    # unique triads should be limited to either 3x or 4x, as confirmed by th
    # poly method (convex = true, uniqueness = true, collinearity = false).
    expect(vtx.size).to eq(3)
    expect(mod1.poly(vtx, true, true, false).size).to eq(3)
    expect(mod1.status.zero?).to be(true)
    triads = mod1.getTriads(vtx)
    expect(mod1.status.zero?).to be(true)
    expect(triads.size).to eq(3)
  end

  it "checks ULC" do
    expect(mod1.reset(DBG)).to eq(DBG)
    expect(mod1.level).to eq(DBG)
    expect(mod1.clean!).to eq(DBG)

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # Regular polygon, counterclockwise yet not UpperLeftCorner (ULC).
    vtx  = OpenStudio::Point3dVector.new
    vtx << OpenStudio::Point3d.new(20, 0, 10)
    vtx << OpenStudio::Point3d.new( 0, 0, 10)
    vtx << OpenStudio::Point3d.new( 0, 0,  0)
    vtx << OpenStudio::Point3d.new(20, 0,  0)
    t         = OpenStudio::Transformation.alignFace(vtx)
    a_vtx     = t.inverse * vtx

    # 1. Native ULC reordering.
    ulc_a_vtx = OpenStudio.reorderULC(a_vtx)
    ulc_vtx   = t * ulc_a_vtx
    # puts ulc_vtx
    # [20, 0,  0]
    # [20, 0, 10]
    # [ 0, 0, 10]
    # [ 0, 0,  0]
    expect(ulc_vtx[3].x.abs).to be < TOL
    expect(ulc_vtx[3].y.abs).to be < TOL
    expect(ulc_vtx[3].z.abs).to be < TOL # ... counterclockwise, yet ULC?

    # 2. OSut ULC reordering.
    ulc_a_vtx = mod1.ulc(a_vtx)
    ulc_vtx   = t * ulc_a_vtx
    expect(mod1.status.zero?).to be(true)
    expect(ulc_vtx[1].x.abs).to be < TOL
    expect(ulc_vtx[1].y.abs).to be < TOL
    expect(ulc_vtx[1].z.abs).to be < TOL
    # puts ulc_vtx
    # [ 0, 0, 10]
    # [ 0, 0,  0]
    # [20, 0,  0]
    # [20, 0, 10]

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # Same, yet (0,0,0) is at index == 0.
    vtx  = OpenStudio::Point3dVector.new
    vtx << OpenStudio::Point3d.new( 0, 0,  0)
    vtx << OpenStudio::Point3d.new(20, 0,  0)
    vtx << OpenStudio::Point3d.new(20, 0, 10)
    vtx << OpenStudio::Point3d.new( 0, 0, 10)
    t         = OpenStudio::Transformation.alignFace(vtx)
    a_vtx     = t.inverse * vtx

    # 1. Native ULC reordering.
    ulc_a_vtx = OpenStudio.reorderULC(a_vtx)
    ulc_vtx   = t * ulc_a_vtx
    # puts ulc_vtx
    # [20, 0,  0]
    # [20, 0, 10]
    # [ 0, 0, 10]
    # [ 0, 0,  0] # ... consistent with first case.

    # 2. OSut ULC reordering.
    ulc_a_vtx = mod1.ulc(a_vtx)
    ulc_vtx   = t * ulc_a_vtx
    expect(mod1.status.zero?).to be(true)
    expect(ulc_vtx[1].x.abs).to be < TOL
    expect(ulc_vtx[1].y.abs).to be < TOL
    expect(ulc_vtx[1].z.abs).to be < TOL
    # puts ulc_vtx
    # [ 0, 0, 10]
    # [ 0, 0,  0]
    # [20, 0,  0]
    # [20, 0, 10]

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # Irregular polygon, no point at 0,0,0.
    vtx = OpenStudio::Point3dVector.new
    vtx << OpenStudio::Point3d.new(18, 0, 10)
    vtx << OpenStudio::Point3d.new( 2, 0, 10)
    vtx << OpenStudio::Point3d.new( 0, 0,  5)
    vtx << OpenStudio::Point3d.new( 2, 0,  0)
    vtx << OpenStudio::Point3d.new(18, 0,  0)
    vtx << OpenStudio::Point3d.new(20, 0,  5)
    t         = OpenStudio::Transformation.alignFace(vtx)
    a_vtx     = t.inverse * vtx

    # 1. Native ULC reordering.
    ulc_a_vtx = OpenStudio.reorderULC(a_vtx)
    ulc_vtx   = t * ulc_a_vtx
    # puts ulc_vtx
    # [18, 0,  0]
    # [20, 0,  5]
    # [18, 0, 10]
    # [ 2, 0, 10]
    # [ 0, 0,  5]
    # [ 2, 0,  0] ... consistent pattern with previous cases, yet ULC?

    # 2. OSut ULC reordering.
    ulc_a_vtx = mod1.ulc(a_vtx)
    ulc_vtx   = t * ulc_a_vtx
    expect(mod1.status.zero?).to be(true)
    expect(ulc_vtx[1].x.abs).to be < TOL
    expect(ulc_vtx[1].y.abs).to be < TOL
    expect(ulc_vtx[1].z.abs).to be > TOL
    # puts ulc_vtx
    # [ 2, 0, 10]
    # [ 0, 0,  5]
    # [ 2, 0,  0]
    # [18, 0,  0]
    # [20, 0,  5]
    # [18, 0, 10]
  end

  it "checks polygon attributes" do
    expect(mod1.reset(INF)).to eq(INF)
    expect(mod1.level).to eq(INF)
    expect(mod1.clean!).to eq(INF)

    # 2x points (not a polygon).
    vtx  = OpenStudio::Point3dVector.new
    vtx << OpenStudio::Point3d.new( 0, 0,10)
    vtx << OpenStudio::Point3d.new( 0, 0,10)
    v = mod1.poly(vtx)
    expect(v.is_a?(OpenStudio::Point3dVector)).to be(true)
    expect(v.empty?).to be(true)
    expect(mod1.error?).to be(true)
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message].include?("Empty 'polygon'")).to be(true)
    expect(mod1.clean!).to eq(INF)

    # 3x non-unique points (not a polygon).
    vtx  = OpenStudio::Point3dVector.new
    vtx << OpenStudio::Point3d.new( 0, 0,10)
    vtx << OpenStudio::Point3d.new( 0, 0,10)
    vtx << OpenStudio::Point3d.new( 0, 0,10)
    v = mod1.poly(vtx)
    expect(v.is_a?(OpenStudio::Point3dVector)).to be(true)
    expect(v.empty?).to be(true)
    expect(mod1.error?).to be(true)
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message].include?("Empty 'polygon'")).to be(true)
    expect(mod1.clean!).to eq(INF)

    # 4th non-planar point (not a polygon).
    vtx  = OpenStudio::Point3dVector.new
    vtx << OpenStudio::Point3d.new( 0, 0,10)
    vtx << OpenStudio::Point3d.new( 0, 0, 0)
    vtx << OpenStudio::Point3d.new(10, 0, 0)
    vtx << OpenStudio::Point3d.new( 0,10,10)
    v = mod1.poly(vtx)
    expect(v.is_a?(OpenStudio::Point3dVector)).to be(true)
    expect(v.empty?).to be(true)
    expect(mod1.error?).to be(true)
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message].include?("plane")).to be(true)
    expect(mod1.clean!).to eq(INF)

    # 3x unique points (a valid polygon).
    vtx  = OpenStudio::Point3dVector.new
    vtx << OpenStudio::Point3d.new( 0, 0,10)
    vtx << OpenStudio::Point3d.new( 0, 0, 0)
    vtx << OpenStudio::Point3d.new(10, 0, 0)
    v = mod1.poly(vtx)
    expect(v.is_a?(OpenStudio::Point3dVector)).to be(true)
    expect(v.size).to eq(3)
    expect(mod1.status.zero?).to be(true)

    # 4th collinear point (collinear permissive).
    vtx << OpenStudio::Point3d.new(20, 0, 0)
    v = mod1.poly(vtx)
    expect(v.is_a?(OpenStudio::Point3dVector)).to be(true)
    expect(v.size).to eq(4)
    expect(mod1.status.zero?).to be(true)

    # Intersecting points, e.g. a 'bowtie' (not a valid Openstudio polygon).
    vtx  = OpenStudio::Point3dVector.new
    vtx << OpenStudio::Point3d.new( 0, 0,10)
    vtx << OpenStudio::Point3d.new( 0, 0, 0)
    vtx << OpenStudio::Point3d.new(10, 0,10)
    vtx << OpenStudio::Point3d.new( 0,10, 0)
    v = mod1.poly(vtx)
    expect(v.is_a?(OpenStudio::Point3dVector)).to be(true)
    expect(v.empty?).to be(true)
    expect(mod1.error?).to be(true)
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message].include?("Empty 'plane'")).to be(true)
    expect(mod1.clean!).to eq(INF)

    # Ensure uniqueness & OpenStudio's counterclockwise ULC sequence.
    vtx  = OpenStudio::Point3dVector.new
    vtx << OpenStudio::Point3d.new( 0, 0,10)
    vtx << OpenStudio::Point3d.new( 0, 0, 0)
    vtx << OpenStudio::Point3d.new(10, 0, 0)
    vtx << OpenStudio::Point3d.new(10, 0, 0)
    v = mod1.poly(vtx, false, true, true, false, :ulc)
    expect(v.is_a?(OpenStudio::Point3dVector)).to be(true)
    expect(v.size).to eq(3)
    expect(mod1.same?(vtx[0], v[0])).to be(true)
    expect(mod1.same?(vtx[1], v[1])).to be(true)
    expect(mod1.same?(vtx[2], v[2])).to be(true)
    expect(mod1.status.zero?).to be(true)
    expect(mod1.clean!).to eq(INF)

    # Ensure strict non-collinearity (ULC).
    vtx  = OpenStudio::Point3dVector.new
    vtx << OpenStudio::Point3d.new( 0, 0,10)
    vtx << OpenStudio::Point3d.new( 0, 0, 0)
    vtx << OpenStudio::Point3d.new(10, 0, 0)
    vtx << OpenStudio::Point3d.new(20, 0, 0)
    v = mod1.poly(vtx, false, false, false, false, :ulc)
    expect(v.is_a?(OpenStudio::Point3dVector)).to be(true)
    expect(v.size).to eq(3)
    expect(mod1.same?(vtx[0], v[0])).to be(true)
    expect(mod1.same?(vtx[1], v[1])).to be(true)
    expect(mod1.same?(vtx[3], v[2])).to be(true)
    expect(mod1.status.zero?).to be(true)
    expect(mod1.clean!).to eq(INF)

    # Ensuring strict non-collinearity also ensures uniqueness (ULC).
    vtx  = OpenStudio::Point3dVector.new
    vtx << OpenStudio::Point3d.new( 0, 0,10)
    vtx << OpenStudio::Point3d.new( 0, 0, 0)
    vtx << OpenStudio::Point3d.new( 0, 0, 0)
    vtx << OpenStudio::Point3d.new(10, 0, 0)
    vtx << OpenStudio::Point3d.new(20, 0, 0)
    v = mod1.poly(vtx, false, false, false, false, :ulc)
    expect(v.is_a?(OpenStudio::Point3dVector)).to be(true)
    expect(v.size).to eq(3)
    expect(mod1.same?(vtx[0], v[0])).to be(true)
    expect(mod1.same?(vtx[1], v[1])).to be(true)
    expect(mod1.same?(vtx[4], v[2])).to be(true)
    expect(mod1.status.zero?).to be(true)
    expect(mod1.clean!).to eq(INF)

    # Check for (valid) convexity.
    vtx  = OpenStudio::Point3dVector.new
    vtx << OpenStudio::Point3d.new( 0, 0,10)
    vtx << OpenStudio::Point3d.new( 0, 0, 0)
    vtx << OpenStudio::Point3d.new(20, 0, 0)
    v = mod1.poly(vtx, true)
    expect(v.is_a?(OpenStudio::Point3dVector)).to be(true)
    expect(v.size).to eq(3)
    expect(mod1.status.zero?).to be(true)

    # Check for (invalid) convexity.
    vtx << OpenStudio::Point3d.new(1, 0, 1)
    v = mod1.poly(vtx, true)
    expect(v.is_a?(OpenStudio::Point3dVector)).to be(true)
    expect(v.empty?).to be(true)
    expect(mod1.error?).to be(true)
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message].include?("non-convex")).to be(true)
    expect(mod1.clean!).to eq(INF)

    # 2nd check for (valid) convexity (with collinear points).
    vtx  = OpenStudio::Point3dVector.new
    vtx << OpenStudio::Point3d.new( 0, 0,10)
    vtx << OpenStudio::Point3d.new( 0, 0, 0)
    vtx << OpenStudio::Point3d.new(10, 0, 0)
    vtx << OpenStudio::Point3d.new(20, 0, 0)
    v = mod1.poly(vtx, true, false, true, false, :ulc)
    expect(v.is_a?(OpenStudio::Point3dVector)).to be(true)
    expect(v.size).to eq(4)
    expect(mod1.same?(vtx[0], v[0])).to be(true)
    expect(mod1.same?(vtx[1], v[1])).to be(true)
    expect(mod1.same?(vtx[2], v[2])).to be(true)
    expect(mod1.same?(vtx[3], v[3])).to be(true)
    expect(mod1.status.zero?).to be(true)

    # 2nd check for (invalid) convexity (with collinear points).
    vtx << OpenStudio::Point3d.new(1, 0, 1)
    v = mod1.poly(vtx, true, false, true, false, :ulc)
    expect(v.is_a?(OpenStudio::Point3dVector)).to be(true)
    expect(v.empty?).to be(true)
    expect(mod1.error?).to be(true)
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message].include?("non-convex")).to be(true)
    expect(mod1.clean!).to eq(INF)

    # 3rd check for (valid) convexity (with collinear points), yet returned
    # 3D points vector remains 'aligned' & clockwise.
    vtx  = OpenStudio::Point3dVector.new
    vtx << OpenStudio::Point3d.new( 0, 0,10)
    vtx << OpenStudio::Point3d.new( 0, 0, 0)
    vtx << OpenStudio::Point3d.new(10, 0, 0)
    vtx << OpenStudio::Point3d.new(20, 0, 0)
    v = mod1.poly(vtx, true, false, true, true, :cw)
    expect(v.is_a?(OpenStudio::Point3dVector)).to be(true)
    expect(v.size).to eq(4)
    expect(mod1.xyz?(v, :z, 0)).to be(true)
    expect(mod1.clockwise?(v)).to be(true)
    expect(mod1.status.zero?).to be(true)

    # Ensure returned vector remains in original sequence (if unaltered).
    vtx  = OpenStudio::Point3dVector.new
    vtx << OpenStudio::Point3d.new( 0, 0,10)
    vtx << OpenStudio::Point3d.new( 0, 0, 0)
    vtx << OpenStudio::Point3d.new(10, 0, 0)
    vtx << OpenStudio::Point3d.new(20, 0, 0)
    v = mod1.poly(vtx, true, false, true, false, :no)
    expect(v.is_a?(OpenStudio::Point3dVector)).to be(true)
    expect(v.size).to eq(4)
    expect(mod1.same?(vtx[0], v[0])).to be(true)
    expect(mod1.same?(vtx[1], v[1])).to be(true)
    expect(mod1.same?(vtx[2], v[2])).to be(true)
    expect(mod1.same?(vtx[3], v[3])).to be(true)
    expect(mod1.status.zero?).to be(true)

    # Sequence of returned vector if altered (avoid collinearity).
    vtx  = OpenStudio::Point3dVector.new
    vtx << OpenStudio::Point3d.new( 0, 0,10)
    vtx << OpenStudio::Point3d.new( 0, 0, 0)
    vtx << OpenStudio::Point3d.new(10, 0, 0)
    vtx << OpenStudio::Point3d.new(20, 0, 0)
    v = mod1.poly(vtx, true, false, false, false, :no)
    expect(v.is_a?(OpenStudio::Point3dVector)).to be(true)
    expect(v.size).to eq(3)
    expect(mod1.same?(vtx[0], v[0])).to be(true)
    expect(mod1.same?(vtx[1], v[1])).to be(true)
    expect(mod1.same?(vtx[3], v[2])).to be(true)
    expect(mod1.status.zero?).to be(true)
  end

  it "checks subsurface insertions on (seb) tilted surfaces" do
    # Examples of how to harness OpenStudio's Boost geometry methods to safely
    # insert subsurfaces along rotated/tilted/slanted host/parent/base
    # surfaces. First step, modify SEB.osm model.
    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    expect(mod1.reset(DBG)).to eq(DBG)
    expect(mod1.level).to eq(DBG)
    expect(mod1.clean!).to eq(DBG)

    translator = OpenStudio::OSVersion::VersionTranslator.new
    v = OpenStudio.openStudioVersion.split(".").join.to_i
    file = File.join(__dir__, "files/osms/in/seb.osm")
    path = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model.empty?).to be(false)
    model = model.get

    openarea = model.getSpaceByName("Open area 1")
    expect(openarea.empty?).to be(false)
    openarea = openarea.get
    expect(openarea.isEnclosedVolume).to be(true)       unless v < 350
    expect(openarea.isVolumeDefaulted).to be(true)      unless v < 350
    expect(openarea.isVolumeAutocalculated).to be(true) unless v < 350

    w5 = model.getSurfaceByName("Openarea 1 Wall 5")
    expect(w5.empty?).to be(false)
    w5 = w5.get
    w5_space = w5.space
    expect(w5_space.empty?).to be(false)
    w5_space = w5_space.get
    expect(w5_space).to eq(openarea)
    expect(w5.vertices.size).to eq(4)

    # Delete w5, and replace with 1x slanted roof + 3x walls (1x tilted).
    # Keep w5 coordinates in memory (before deleting), as anchor points for the
    # 4x new surfaces.
    w5_0 = w5.vertices[0]
    w5_1 = w5.vertices[1]
    w5_2 = w5.vertices[2]
    w5_3 = w5.vertices[3]

    w5.remove

    # 2x new points.
    roof_left  = OpenStudio::Point3d.new( 0.2166, 12.7865, 2.3528)
    roof_right = OpenStudio::Point3d.new(-5.4769, 11.2626, 2.3528)
    length     = (roof_left - roof_right).length

    # New slanted roof.
    vec  = OpenStudio::Point3dVector.new
    vec << w5_0
    vec << roof_left
    vec << roof_right
    vec << w5_3
    roof = OpenStudio::Model::Surface.new(vec, model)
    roof.setName("Openarea slanted roof")
    expect(roof.setSurfaceType("RoofCeiling")).to be(true)
    expect(roof.setSpace(openarea)).to be(true)

    # Side-note test: genConstruction --- --- --- --- --- --- --- --- --- --- #
    expect(roof.isConstructionDefaulted).to be(true)
    lc = roof.construction
    expect(lc.empty?).to be(false)
    lc = lc.get.to_LayeredConstruction
    expect(lc.empty?).to be(false)
    lc = lc.get
    c  = mod1.genConstruction(model, {type: :roof, uo: 1 / 5.46})
    expect(mod1.status.zero?).to be(true)
    expect(c.is_a?(OpenStudio::Model::LayeredConstruction)).to be(true)
    expect(roof.setConstruction(c)).to be(true)
    expect(roof.isConstructionDefaulted).to be(false)
    r1 = mod1.rsi(lc)
    r2 = mod1.rsi(c)
    d1 = mod1.rsi(lc)
    d2 = mod1.rsi(c)
    expect((r1 - r2).abs > 0).to be(true)
    expect((d1 - d2).abs > 0).to be(true)
    # ... end of genConstruction test --- --- --- --- --- --- --- --- --- --- #

    # New, inverse-tilted wall (i.e. cantilevered), under new slanted roof.
    vec  = OpenStudio::Point3dVector.new
    # vec << roof_left  # TOPLEFT
    # vec << w5_1       # BOTTOMLEFT
    # vec << w5_2       # BOTTOMRIGHT
    # vec << roof_right # TOPRIGHT

    # Test if starting instead from BOTTOMRIGHT (i.e. upside-down "U").
    vec << w5_2       # BOTTOMRIGHT
    vec << roof_right # TOPRIGHT
    vec << roof_left  # TOPLEFT
    vec << w5_1       # BOTTOMLEFT
    tilt_wall = OpenStudio::Model::Surface.new(vec, model)
    tilt_wall.setName("Openarea tilted wall")
    expect(tilt_wall.setSurfaceType("Wall")).to be(true)
    expect(tilt_wall.setSpace(openarea)).to be(true)

    # New, left side wall.
    vec  = OpenStudio::Point3dVector.new
    vec << w5_0
    vec << w5_1
    vec << roof_left
    left_wall = OpenStudio::Model::Surface.new(vec, model)
    left_wall.setName("Openarea left side wall")
    expect(left_wall.setSpace(openarea)).to be(true)

    # New, right side wall.
    vec  = OpenStudio::Point3dVector.new
    vec << w5_3
    vec << roof_right
    vec << w5_2
    right_wall = OpenStudio::Model::Surface.new(vec, model)
    right_wall.setName("Openarea right side wall")
    expect(right_wall.setSpace(openarea)).to be(true)

    expect(openarea.isEnclosedVolume).to be(true)       unless v < 350
    expect(openarea.isVolumeDefaulted).to be(true)      unless v < 350
    expect(openarea.isVolumeAutocalculated).to be(true) unless v < 350

    file = File.join(__dir__, "files/osms/out/seb_mod.osm")
    model.save(file, true)

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # Fetch transform if tilted wall vertices were to "align", i.e.:
    #   - rotated/tilted
    #   - then flattened along XY plane
    #   - all Z-axis coordinates == ~0
    #   - vertices with the lowest X-axis values are aligned along X-axis (0)
    #   - vertices with the lowest Z-axis values ares aligned along Y-axis (0)
    #   - Z-axis values are represented as Y-axis values
    tr = OpenStudio::Transformation.alignFace(tilt_wall.vertices)
    aligned_tilt_wall = tr.inverse * tilt_wall.vertices
    expect(aligned_tilt_wall.is_a?(Array)).to be(true)
    # puts aligned_tilt_wall
    # [4.89, 0.00, 0.00] # if BOTTOMRIGHT, i.e. upside-down "U"
    # [5.89, 3.09, 0.00]
    # [0.00, 3.09, 0.00]
    # [1.00, 0.00, 0.00]
    # ... no change in results (once sub surfaces are added below), as 'addSubs'
    # does not rely 'directly' on World or Relative XYZ coordinates of the base
    # surface. It instead relies on base surface width/height (once 'aligned'),
    # regardless of the user-defined sequence of vertices.

    # Find centerline along "aligned" X-axis, and upper Y-axis limit.
    min_x = 0
    max_x = 0
    max_y = 0

    aligned_tilt_wall.each do |vec|
      min_x = vec.x if vec.x < min_x
      max_x = vec.x if vec.x > max_x
      max_y = vec.y if vec.y > max_y
    end

    centerline = (max_x - min_x) / 2
    expect(centerline * 2).to be_within(TOL).of(length)

    # Subsurface dimensions (e.g. window/skylight).
    width  = 0.5
    height = 1.0

    # Add 3x new, tilted windows along the tilted wall upper horizontal edge
    # (i.e. max_Y), then realign with original tilted wall. Insert using 5mm
    # buffer, IF inserted along any host/parent/base surface edge, e.g. door
    # sill. Boost-based alignement/realignment does introduce small errors, and
    # EnergyPlus may raise warnings of overlaps between host/base/parent
    # surface and any of its new subsurface(s). Why 5mm (vs 25mm)? Keeping
    # buffer under 10mm, see: https://rd2.github.io/tbd/pages/subs.html.
    y = max_y - 0.005

    x    = centerline - width / 2 # center window
    vec  = OpenStudio::Point3dVector.new
    vec << OpenStudio::Point3d.new(x,         y,          0)
    vec << OpenStudio::Point3d.new(x,         y - height, 0)
    vec << OpenStudio::Point3d.new(x + width, y - height, 0)
    vec << OpenStudio::Point3d.new(x + width, y,          0)

    tilt_window1 = OpenStudio::Model::SubSurface.new(tr * vec, model)
    tilt_window1.setName("Tilted window (center)")
    expect(tilt_window1.setSubSurfaceType("FixedWindow")).to be(true)
    expect(tilt_window1.setSurface(tilt_wall)).to be(true)

    x    = centerline - 3*width/2 - 0.15 # window to the left of the first one
    vec  = OpenStudio::Point3dVector.new
    vec << OpenStudio::Point3d.new(x,         y,          0)
    vec << OpenStudio::Point3d.new(x,         y - height, 0)
    vec << OpenStudio::Point3d.new(x + width, y - height, 0)
    vec << OpenStudio::Point3d.new(x + width, y,          0)

    tilt_window2 = OpenStudio::Model::SubSurface.new(tr * vec, model)
    tilt_window2.setName("Tilted window (left)")
    expect(tilt_window2.setSubSurfaceType("FixedWindow")).to be(true)
    expect(tilt_window2.setSurface(tilt_wall)).to be(true)

    x    = centerline + width/2 + 0.15 # window to the right of the first one
    vec  = OpenStudio::Point3dVector.new
    vec << OpenStudio::Point3d.new(x,         y,          0)
    vec << OpenStudio::Point3d.new(x,         y - height, 0)
    vec << OpenStudio::Point3d.new(x + width, y - height, 0)
    vec << OpenStudio::Point3d.new(x + width, y,          0)

    tilt_window3 = OpenStudio::Model::SubSurface.new(tr * vec, model)
    tilt_window3.setName("Tilted window (right)")
    expect(tilt_window3.setSubSurfaceType("FixedWindow")).to be(true)
    expect(tilt_window3.setSurface(tilt_wall)).to be(true)

    # file = File.join(__dir__, "files/osms/out/seb_fen.osm")
    # model.save(file, true)

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # Repeat for 3x skylights. Fetch transform if slanted roof vertices were
    # also to "align". Recover the (default) window construction.
    expect(tilt_window1.isConstructionDefaulted).to be(true)
    construction = tilt_window1.construction
    expect(construction.empty?).to be(false)
    construction = construction.get

    tr = OpenStudio::Transformation.alignFace(roof.vertices)
    aligned_roof = tr.inverse * roof.vertices
    expect(aligned_roof.is_a?(Array)).to be(true)

    # Find centerline along "aligned" X-axis, and lower Y-axis limit.
    min_x = 0
    max_x = 0
    min_y = 0

    aligned_tilt_wall.each do |vec|
      min_x = vec.x if vec.x < min_x
      max_x = vec.x if vec.x > max_x
      min_y = vec.y if vec.y < min_y
    end

    centerline = (max_x - min_x) / 2
    expect(centerline * 2).to be_within(TOL).of(length)

    # Add 3x new, slanted skylights aligned along upper horizontal edge of roof
    # (i.e. min_Y), then realign with original roof.
    y = min_y + 0.005

    x    = centerline - width / 2 # center skylight
    vec  = OpenStudio::Point3dVector.new
    vec << OpenStudio::Point3d.new(x,         y + height, 0)
    vec << OpenStudio::Point3d.new(x,         y,          0)
    vec << OpenStudio::Point3d.new(x + width, y,          0)
    vec << OpenStudio::Point3d.new(x + width, y + height, 0)

    skylight1 = OpenStudio::Model::SubSurface.new(tr * vec, model)
    skylight1.setName("Skylight (center)")
    expect(skylight1.setSubSurfaceType("Skylight")).to be(true)
    expect(skylight1.setConstruction(construction)).to be(true)
    expect(skylight1.setSurface(roof)).to be(true)

    x    = centerline - 3*width/2 - 0.15 # skylight to the left of center
    vec  = OpenStudio::Point3dVector.new
    vec << OpenStudio::Point3d.new(x,         y + height, 0)
    vec << OpenStudio::Point3d.new(x,         y         , 0)
    vec << OpenStudio::Point3d.new(x + width, y         , 0)
    vec << OpenStudio::Point3d.new(x + width, y + height, 0)

    skylight2 = OpenStudio::Model::SubSurface.new(tr * vec, model)
    skylight2.setName("Skylight (left)")
    expect(skylight2.setSubSurfaceType("Skylight")).to be(true)
    expect(skylight2.setConstruction(construction)).to be(true)
    expect(skylight2.setSurface(roof)).to be(true)

    x    = centerline + width/2 + 0.15 # skylight to the right of center
    vec  = OpenStudio::Point3dVector.new
    vec << OpenStudio::Point3d.new(x,         y + height, 0)
    vec << OpenStudio::Point3d.new(x,         y         , 0)
    vec << OpenStudio::Point3d.new(x + width, y         , 0)
    vec << OpenStudio::Point3d.new(x + width, y + height, 0)

    skylight3 = OpenStudio::Model::SubSurface.new(tr * vec, model)
    skylight3.setName("Skylight (right)")
    expect(skylight3.setSubSurfaceType("Skylight")).to be(true)
    expect(skylight3.setConstruction(construction)).to be(true)
    expect(skylight3.setSurface(roof)).to be(true)

    file = File.join(__dir__, "files/osms/out/seb_ext1.osm")
    model.save(file, true)

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # Now test the same result when relying on OSut::addSub.
    file = File.join(__dir__, "files/osms/out/seb_mod.osm")
    path = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model.empty?).to be(false)
    model = model.get

    roof = model.getSurfaceByName("Openarea slanted roof")
    expect(roof.empty?).to be(false)
    roof = roof.get

    tilt_wall = model.getSurfaceByName("Openarea tilted wall")
    expect(tilt_wall.empty?).to be(false)
    tilt_wall = tilt_wall.get

    head   = max_y - 0.005
    offset = width + 0.15

    # Add array of 3x windows to tilted wall.
    sub = {}
    sub[:id    ] = "Tilted window"
    sub[:height] = height
    sub[:width ] = width
    sub[:head  ] = head
    sub[:count ] = 3
    sub[:offset] = offset
    # sub[:type  ] = "FixedWindow" # defaulted if not specified.
    expect(mod1.addSubs(model, tilt_wall, [sub])).to be(true)
    expect(mod1.status.zero?).to be(true)
    expect(mod1.logs.size.zero?).to be(true)

    tilted = model.getSubSurfaceByName("Tilted window|0")
    expect(tilted.empty?).to be(false)
    tilted = tilted.get
    construction = tilted.construction
    expect(construction.empty?).to be(false)
    construction = construction.get
    sub[:assembly] = construction

    sub.delete(:head)
    expect(sub.key?(:head)).to be(false)
    sub[:id  ] = ""
    sub[:sill] = 0.0 # will be reset to 5mm
    sub[:type] = "Skylight"
    expect(mod1.addSubs(model, roof, [sub])).to be(true)
    expect(mod1.warn?).to be(true)
    expect(mod1.logs.size).to eq(1)
    message = "' sill height to 0.005 m (OSut::addSubs)"
    expect(mod1.logs.first[:message].include?(message)).to be(true)

    file = File.join(__dir__, "files/osms/out/seb_ext2.osm")
    model.save(file, true)
  end

  it "checks wwr insertions (seb)" do
    expect(mod1.reset(DBG)).to eq(DBG)
    expect(mod1.level).to eq(DBG)
    expect(mod1.clean!).to eq(DBG)

    wwr = 0.10

    translator = OpenStudio::OSVersion::VersionTranslator.new
    v = OpenStudio.openStudioVersion.split(".").join.to_i
    file = File.join(__dir__, "files/osms/out/seb_ext2.osm")
    path = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model.empty?).to be(false)
    model = model.get

    # Fetch "Openarea Wall 3".
    wall3 = model.getSurfaceByName("Openarea 1 Wall 3")
    expect(wall3.empty?).to be(false)
    wall3 = wall3.get
    area = wall3.grossArea * wwr

    # Fetch "Openarea Wall 4".
    wall4 = model.getSurfaceByName("Openarea 1 Wall 4")
    expect(wall4.empty?).to be(false)
    wall4 = wall4.get

    # Fetch transform if wall3 vertices were to 'align'.
    tr = OpenStudio::Transformation.alignFace(wall3.vertices)
    a_wall3 = tr.inverse * wall3.vertices
    ymax = a_wall3.map(&:y).max
    xmax = a_wall3.map(&:x).max
    xmid = xmax / 2 # centreline

    # Fetch 'head'/'sill' heights of nearby "Sub Surface 1".
    sub1 = model.getSubSurfaceByName("Sub Surface 1")
    expect(sub1.empty?).to be(false)
    sub1 = sub1.get
    sub1_min = sub1.vertices.map(&:z).min
    sub1_max = sub1.vertices.map(&:z).max

    # Add 2x window strips, each representing a 10% WWR of wall3 (20% total)
    #   - 1x constrained to sub1 'head' & 'sill'
    #   - 1x contrained only to 2nd 'sill' height
    wwr1         = {}
    wwr1[:id   ] = "OA1 W3 wwr1|10"
    wwr1[:ratio] = 0.1
    wwr1[:head ] = sub1_max
    wwr1[:sill ] = sub1_min

    wwr2         = {}
    wwr2[:id   ] = "OA1 W3 wwr2|10"
    wwr2[:ratio] = 0.1
    wwr2[:sill ] = wwr1[:head] + 0.1

    sbz = [wwr1, wwr2]
    expect(mod1.addSubs(model, wall3, sbz)).to be(true)
    expect(mod1.status.zero?).to be(true)
    sbz = wall3.subSurfaces
    expect(sbz.size).to eq(2)

    sbz.each do |sb|
      expect(sb.grossArea).to be_within(TOL).of(area)
      sb_sill  = sb.vertices.map(&:z).min
      sb_head  = sb.vertices.map(&:z).max

      if sb.nameString.include?("wwr1")
        expect(sb_sill).to be_within(TOL).of(wwr1[:sill])
        expect(sb_head).to be_within(TOL).of(wwr1[:head])
        expect(sb_head).to_not be_within(TOL).of(HEAD)
      else
        expect(sb_sill).to be_within(TOL).of(wwr2[:sill])
        expect(sb_head).to be_within(TOL).of(HEAD) # defaulted
      end
    end

    expect(wall3.windowToWallRatio).to be_within(TOL).of(wwr * 2)

    # Fetch transform if wall4 vertices were to 'align'.
    tr = OpenStudio::Transformation.alignFace(wall4.vertices)
    a_wall4 = tr.inverse * wall4.vertices
    ymax = a_wall4.map(&:y).max
    xmax = a_wall4.map(&:x).max
    xmid = xmax / 2 # centreline

    # Add 4x sub surfaces (with frame & dividers) to wall4:
    #   1. w1: 0.8m-wide opening (head defaulted to HEAD, sill @0m)
    #   2. w2: 0.4m-wide sidelite, to the immediate right of w2 (HEAD, sill@0)
    #   3. t1: 0.8m-wide transom above w1 (0.4m in height)
    #   4. t2: 0.5m-wide transom above w2 (0.4m in height)
    #
    # All 4x sub surfaces are intended to share frame edges (once frame &
    # divider frame widths are taken into account). Postulating a 50mm frame,
    # meaning 100mm between w1, w2, t1 vs t2 vertices. In addition, all 4x
    # openings (grouped together) should align towards the left of wall4,
    # leaving a 200mm gap between the left vertical wall edge and the left
    # frame jamb edge of w1 & t1. First initialize Frame & Divider object.
    gap    = 0.200
    frame  = 0.050
    frames = 2 * frame

    fd = OpenStudio::Model::WindowPropertyFrameAndDivider.new(model)
    expect(fd.setFrameWidth(frame)).to be(true)
    expect(fd.setFrameConductance(2.500)).to be(true)

    w1              = {}
    w1[:id        ] = "OA1 W4 w1"
    w1[:frame     ] = fd
    w1[:width     ] = 0.8
    w1[:head      ] = HEAD
    w1[:sill      ] = 0.005 + frame # to avoid generating a warning
    w1[:centreline] = -xmid + gap + frame + w1[:width]/2

    w2              = {}
    w2[:id        ] = "OA1 W4 w2"
    w2[:frame     ] = fd
    w2[:width     ] = w1[:width     ]/2
    w2[:head      ] = w1[:head      ]
    w2[:sill      ] = w1[:sill      ]
    w2[:centreline] = w1[:centreline] + w1[:width]/2 + frames + w2[:width]/2

    t1              = {}
    t1[:id        ] = "OA1 W4 t1"
    t1[:frame     ] = fd
    t1[:width     ] = w1[:width     ]
    t1[:height    ] = w2[:width     ]
    t1[:sill      ] = w1[:head      ] + frames
    t1[:centreline] = w1[:centreline]

    t2              = {}
    t2[:id        ] = "OA1 W4 t2"
    t2[:frame     ] = fd
    t2[:width     ] = w2[:width     ]
    t2[:height    ] = t1[:height    ]
    t2[:sill      ] = t1[:sill      ]
    t2[:centreline] = w2[:centreline]

    sbz = [w1, w2, t1, t2]
    expect(mod1.addSubs(model, wall4, sbz)).to be(true)
    expect(mod1.status.zero?).to be(true)


    # Add another 5x (frame&divider-enabled) fixed windows, from either
    # left- or right-corner of base surfaces. Fetch "Openarea Wall 6".
    wall6 = model.getSurfaceByName("Openarea 1 Wall 6")
    expect(wall6.empty?).to be(false)
    wall6 = wall6.get

    # Fetch "Openarea Wall 7".
    wall7 = model.getSurfaceByName("Openarea 1 Wall 7")
    expect(wall7.empty?).to be(false)
    wall7 = wall7.get

    # Fetch 'head'/'sill' heights of nearby "Sub Surface 6".
    sub6 = model.getSubSurfaceByName("Sub Surface 6")
    expect(sub6.empty?).to be(false)
    sub6 = sub6.get
    sub6_min = sub6.vertices.map(&:z).min
    sub6_max = sub6.vertices.map(&:z).max

    # 1x Array of 3x windows, 8" from the left corner of wall6.
    a6              = {}
    a6[:id        ] = "OA1 W6 a6"
    a6[:count     ] = 3
    a6[:frame     ] = fd
    a6[:head      ] = sub6_max
    a6[:sill      ] = sub6_min
    a6[:width     ] = a6[:head ] - a6[:sill]
    a6[:offset    ] = a6[:width] + gap
    a6[:l_buffer  ] = gap

    expect(mod1.addSubs(model, wall6, [a6])).to be(true)
    expect(mod1.status.zero?).to be(true)

    # 1x Array of 2x square windows, 8" from the right corner of wall7.
    a7              = {}
    a7[:id        ] = "OA1 W6 a7"
    a7[:count     ] = 2
    a7[:frame     ] = fd
    a7[:head      ] = sub6_max
    a7[:sill      ] = sub6_min
    a7[:width     ] = a7[:head ] - a7[:sill]
    a7[:offset    ] = a7[:width] + gap
    a7[:r_buffer  ] = gap

    expect(mod1.addSubs(model, wall7, [a7])).to be(true)
    expect(mod1.status.zero?).to be(true)

    file = File.join(__dir__, "files/osms/out/seb_ext3.osm")
    model.save(file, true)
  end

  it "checks for space/surface convexity" do
    expect(mod1.reset(DBG)).to eq(DBG)
    expect(mod1.level).to eq(DBG)
    expect(mod1.clean!).to eq(DBG)

    translator = OpenStudio::OSVersion::VersionTranslator.new
    v = OpenStudio.openStudioVersion.split(".").join.to_i
    file = File.join(__dir__, "files/osms/in/smalloffice.osm")
    path = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model.empty?).to be(false)
    model = model.get
    core = nil
    attic = nil

    model.getSpaces.each do |space|
      id = space.nameString
      expect(space.isVolumeAutocalculated).to be(true)        unless v < 350
      expect(space.isCeilingHeightAutocalculated).to be(true) unless v < 350
      expect(space.isPartofTotalFloorAreaDefaulted).to be(false)
      expect(space.isFloorAreaDefaulted).to be(true)          unless v < 350
      expect(space.isFloorAreaAutocalculated).to be(true)     unless v < 350
      expect(space.partofTotalFloorArea).to be(false)         if id == "Attic"
      attic = space                                           if id == "Attic"
      next                                                    if id == "Attic"

      expect(space.partofTotalFloorArea).to be(true)
      # Isolate core as being part of the total floor area (occupied zone) and
      # not having sidelighting.
      next unless space.exteriorWallArea < TOL

      core = space
    end

    core_floor = core.surfaces.select   {|s| s.surfaceType == "Floor"}
    core_ceiling = core.surfaces.select {|s| s.surfaceType == "RoofCeiling"}
    expect(core_floor.size).to eq(1)
    expect(core_ceiling.size).to eq(1)
    core_floor = core_floor.first
    core_ceiling = core_ceiling.first
    attic_floor = core_ceiling.adjacentSurface
    expect(attic_floor.empty?).to be(false)
    attic_floor = attic_floor.get

    expect(core.nameString.include?("Core")).to be(true)
    # 22.69, 13.46, 0,                        !- X,Y,Z Vertex 1 {m}
    # 22.69,  5.00, 0,                        !- X,Y,Z Vertex 2 {m}
    #  5.00,  5.00, 0,                        !- X,Y,Z Vertex 3 {m}
    #  5.00, 13.46, 0;                        !- X,Y,Z Vertex 4 {m}
    # -----,------,--
    # 17.69 x 8.46 = 149.66 m2
    expect(core.floorArea).to be_within(TOL).of(149.66)
    core_volume = core.floorArea * core.ceilingHeight
    expect(core_volume).to be_within(TOL).of(core.volume)
    expect(attic.volume).to be_within(TOL).of(720.19)
    expect(attic.floorArea).to be_within(TOL).of(567.98)

    expect(mod1.poly(core_floor, true).empty?).to be(false)   # convex
    expect(mod1.poly(core_ceiling, true).empty?).to be(false) # convex
    expect(mod1.poly(attic_floor, true).empty?).to be(false)  # convex
    expect(mod1.status.zero?).to be(true)

    # Insert new 'mini' (2m x 2m) floor/ceiling at the centre of the existing
    # core space. Initial insertion resorting strictly to adding leader lines
    # from the initial core floor/ceiling vertices to the new 'mini'
    # floor/ceiling.
    centre = OpenStudio::getCentroid(core_floor.vertices)
    expect(centre.empty?).to be(false)
    centre = centre.get
    mini_w = centre.x - 1 # 12.845
    mini_e = centre.x + 1 # 14.845
    mini_n = centre.y + 1 # 10.230
    mini_s = centre.y - 1 #  8.230
    mini_floor_vtx = OpenStudio::Point3dVector.new
    mini_floor_vtx << OpenStudio::Point3d.new(mini_e, mini_n, 0)
    mini_floor_vtx << OpenStudio::Point3d.new(mini_e, mini_s, 0)
    mini_floor_vtx << OpenStudio::Point3d.new(mini_w, mini_s, 0)
    mini_floor_vtx << OpenStudio::Point3d.new(mini_w, mini_n, 0)
    mini_floor = OpenStudio::Model::Surface.new(mini_floor_vtx, model)
    mini_floor.setName("Mini floor")
    expect(mini_floor.outsideBoundaryCondition).to eq("Ground")
    expect(mini_floor.setSpace(core)).to be(true)

    mini_ceiling_vtx = OpenStudio::Point3dVector.new
    mini_ceiling_vtx << OpenStudio::Point3d.new(mini_w, mini_n, 3.05)
    mini_ceiling_vtx << OpenStudio::Point3d.new(mini_w, mini_s, 3.05)
    mini_ceiling_vtx << OpenStudio::Point3d.new(mini_e, mini_s, 3.05)
    mini_ceiling_vtx << OpenStudio::Point3d.new(mini_e, mini_n, 3.05)
    mini_ceiling = OpenStudio::Model::Surface.new(mini_ceiling_vtx, model)
    mini_ceiling.setName("Mini ceiling")
    expect(mini_ceiling.setSpace(core)).to be(true)

    mini_attic_vtx = OpenStudio::Point3dVector.new
    mini_attic_vtx << OpenStudio::Point3d.new(mini_e, mini_n, 3.05)
    mini_attic_vtx << OpenStudio::Point3d.new(mini_e, mini_s, 3.05)
    mini_attic_vtx << OpenStudio::Point3d.new(mini_w, mini_s, 3.05)
    mini_attic_vtx << OpenStudio::Point3d.new(mini_w, mini_n, 3.05)
    mini_attic = OpenStudio::Model::Surface.new(mini_attic_vtx, model)
    mini_attic.setName("Mini attic")
    expect(mini_attic.setSpace(attic)).to be(true)

    expect(mini_ceiling.setAdjacentSurface(mini_attic)).to be(true)
    expect(mini_ceiling.outsideBoundaryCondition).to eq("Surface")
    expect(mini_attic.outsideBoundaryCondition).to eq("Surface")
    expect(mini_ceiling.outsideBoundaryCondition).to eq("Surface")
    expect(mini_ceiling.outsideBoundaryCondition).to eq("Surface")
    expect(mini_ceiling.adjacentSurface.empty?).to be(false)
    expect(mini_attic.adjacentSurface.empty?).to be(false)
    expect(mini_ceiling.adjacentSurface.get).to eq(mini_attic)
    expect(mini_attic.adjacentSurface.get).to eq(mini_ceiling)

    # Reset existing core floor, core ceiling & attic floor vertices to
    # accomodate 3x new mini 'holes' (filled in by the 3x new 'mini' surfaces).
    # To ensure valid (core and attic) area & volume calculations (and avoid
    # OpenStudio stdout errors/warnings), append the last vertex of the
    # original surface vertices: each EnergyPlus edge must be referenced twice
    # (i.e. the 'leader line' between each of the 3x original base surfaces
    # and each of the 'mini' holes must be doubled).
    vtx = OpenStudio::Point3dVector.new
    core_floor.vertices.each {|v| vtx << v}
    vtx << mini_floor_vtx[0]
    vtx << mini_floor_vtx[3]
    vtx << mini_floor_vtx[2]
    vtx << mini_floor_vtx[1]
    vtx << mini_floor_vtx[0]
    vtx << vtx[3]
    expect(core_floor.setVertices(vtx)).to be(true)

    vtx = OpenStudio::Point3dVector.new
    core_ceiling.vertices.each {|v| vtx << v}
    vtx << mini_ceiling_vtx[2]
    vtx << mini_ceiling_vtx[1]
    vtx << mini_ceiling_vtx[0]
    vtx << mini_ceiling_vtx[3]
    vtx << mini_ceiling_vtx[2]
    vtx << vtx[3]
    expect(core_ceiling.setVertices(vtx)).to be(true)

    vtx = OpenStudio::Point3dVector.new
    attic_floor.vertices.each {|v| vtx << v}
    vtx << mini_attic_vtx[0]
    vtx << mini_attic_vtx[3]
    vtx << mini_attic_vtx[2]
    vtx << mini_attic_vtx[1]
    vtx << mini_attic_vtx[0]
    vtx << vtx[3]
    expect(attic_floor.setVertices(vtx)).to be(true)

    # Add 2x skylights to attic.
    attic_south = model.getSurfaceByName("Attic_roof_south")
    expect(attic_south.empty?).to be(false)
    attic_south = attic_south.get

    side   = 1.2
    offset = side + 1
    head   = mod1.height(attic_south.vertices) - 0.2
    expect(head).to be_within(TOL).of(10.16)
    sub = {}
    sub[:id    ] = "South Skylight"
    sub[:type  ] = "Skylight"
    sub[:height] = side
    sub[:width ] = side
    sub[:head  ] = head
    sub[:count ] = 2
    sub[:offset] = offset
    expect(mod1.addSubs(model, attic_south, [sub])).to be(true)
    expect(mod1.status.zero?).to be(true)

    # Re-validating pre-tested areas + volumes, as well as convexity.
    expect(core.floorArea).to be_within(TOL).of(149.66)
    core_volume = core.floorArea * core.ceilingHeight
    expect(core_volume).to be_within(TOL).of(core.volume)
    expect(attic.volume).to be_within(TOL).of(720.19)
    expect(attic.floorArea).to be_within(TOL).of(567.98)

    expect(mod1.poly(core_floor, true).empty?).to be(true)   # now concave
    expect(mod1.poly(core_ceiling, true).empty?).to be(true) # now concave
    expect(mod1.poly(attic_floor, true).empty?).to be(true)  # now concave
    expect(mod1.logs.size).to eq(3)
    expect(mod1.error?).to be(true)
    mod1.logs.each {|l| expect(l[:message].include?("non-convex")).to be(true)}
    expect(mod1.clean!).to eq(DBG)

    shd = model.getShadowCalculation
    # shadingCalculationMethodValues:
    #   - "PolygonClipping"                       # (default)
    #   - "PixelCounting"                         # allows concave, yet **
    #
    #   ** github.com/NREL/EnergyPlus/issues/9059 (no transparent shading yet)
    #
    # polygonClippingAlgorithmValues:
    #   - "ConvexWeilerAthertonSutherlandHodgman" # convex only
    #   - "SlaterBarskyand"                       # rectangular only
    #   - "SutherlandHodgman"                     # (default)
    expect(shd.shadingCalculationMethod).to eq("PolygonClipping")
    expect(shd.polygonClippingAlgorithm).to eq("SutherlandHodgman")

    ctl = model.getSimulationControl
    # validSolarDistributionValues:
    #   - "MinimalShadowing"
    #   - "FullExterior"
    #   - "FullInteriorAndExterior"
    #   - "FullExteriorWithReflections"
    #   - "FullInteriorAndExteriorWithReflections"
    expect(ctl.solarDistribution).to eq("FullInteriorAndExterior")
    expect(ctl.isSolarDistributionDefaulted).to be(false)
    expect(ctl.shadowCalculation.get).to eq(shd)

    file = File.join(__dir__, "files/osms/out/mini.osm")
    model.save(file, true)
    # Simulation results E+ 22.2 (SutherlandHodgman, PolygonClipping)
    # ... no E+ errors/warnings.
    #
    # office.osm  FullInteriorAndExterior                 247 GJ 3.8 UMH cool
    # mini.osm A  FullInteriorAndExterior                 247 GJ 4.0 UMH cool
    # mini.osm B  FullExteriorWithReflections             248 GJ 3.8 UMH cool
    # mini.osm C  FullInteriorAndExteriorWithReflections  247 GJ 3.8 UMH cool

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # Mini as an interior courtyard:
    #   - 4x new outdoor-facing walls (core)
    #   - remove mini floor @Z0 and mini ceiling @Z3.05
    #   - attic mini floor facing outdoors
    vtx = OpenStudio::Point3dVector.new
    vtx << mini_ceiling_vtx[0]
    vtx << mini_floor_vtx[3]
    vtx << mini_floor_vtx[0]
    vtx << mini_ceiling_vtx[3]
    mini_north = OpenStudio::Model::Surface.new(vtx, model)
    mini_north.setName("Mini north")
    expect(mini_north.setSpace(core)).to be(true)
    expect(mini_north.outsideBoundaryCondition).to eq("Outdoors")

    vtx = OpenStudio::Point3dVector.new
    vtx << mini_ceiling_vtx[3]
    vtx << mini_floor_vtx[0]
    vtx << mini_floor_vtx[1]
    vtx << mini_ceiling_vtx[2]
    mini_east = OpenStudio::Model::Surface.new(vtx, model)
    mini_east.setName("Mini east")
    expect(mini_east.setSpace(core)).to be(true)
    expect(mini_east.outsideBoundaryCondition).to eq("Outdoors")

    vtx = OpenStudio::Point3dVector.new
    vtx << mini_ceiling_vtx[2]
    vtx << mini_floor_vtx[1]
    vtx << mini_floor_vtx[2]
    vtx << mini_ceiling_vtx[1]
    mini_south = OpenStudio::Model::Surface.new(vtx, model)
    mini_south.setName("Mini south")
    expect(mini_south.setSpace(core)).to be(true)
    expect(mini_south.outsideBoundaryCondition).to eq("Outdoors")

    vtx = OpenStudio::Point3dVector.new
    vtx << mini_ceiling_vtx[1]
    vtx << mini_floor_vtx[2]
    vtx << mini_floor_vtx[3]
    vtx << mini_ceiling_vtx[0]
    mini_west = OpenStudio::Model::Surface.new(vtx, model)
    mini_west.setName("Mini west")
    expect(mini_west.setSpace(core)).to be(true)
    expect(mini_west.outsideBoundaryCondition).to eq("Outdoors")

    mini_floor.remove
    mini_ceiling.remove
    expect(mini_attic.setOutsideBoundaryCondition("Outdoors")).to be(true)

    # Re-validating pre-tested areas + volumes.
    expect(core.floorArea).to be_within(TOL).of(149.66 - 4) # -mini m2
    core_volume = core.floorArea * core.ceilingHeight
    expect(core_volume).to be_within(TOL).of(core.volume)
    expect(attic.volume).to be_within(TOL).of(720.19)
    expect(attic.floorArea).to be_within(TOL).of(567.98)

    expect(mod1.poly(core_floor, true).empty?).to be(true)   # now concave
    expect(mod1.poly(core_ceiling, true).empty?).to be(true) # now concave
    expect(mod1.poly(attic_floor, true).empty?).to be(true)  # now concave
    expect(mod1.logs.size).to eq(3)
    expect(mod1.error?).to be(true)
    mod1.logs.each {|l| expect(l[:message].include?("non-convex")).to be(true)}
    expect(mod1.clean!).to eq(DBG)

    file = File.join(__dir__, "files/osms/out/mini2.osm")
    model.save(file, true)
    # Simulation results E+ 22.2 (SutherlandHodgman, PolygonClipping)
    # ... no E+ errors/warnings.
    #
    # mini2.osm A  FullInteriorAndExterior                 248 GJ 3.8 UMH cool
    # mini2.osm B  FullExteriorWithReflections             249 GJ 3.7 UMH cool
    # mini2.osm C  FullInteriorAndExteriorWithReflections  249 GJ 3.7 UMH cool

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # Mini as an attic "well":
    #   - reintroduce mini floor @Z0 (ground-facing), as part of attic
    #   - remove attic mini floor @Z3.05
    #   - outdoor-facing courtyard walls become attic "well" walls.
    #   - add interzone attic walls around well.
    mini_floor = OpenStudio::Model::Surface.new(mini_floor_vtx, model)
    mini_floor.setName("Mini floor")
    expect(mini_floor.outsideBoundaryCondition).to eq("Ground")
    expect(mini_floor.setSpace(attic)).to be(true)

    mini_attic.remove

    vtx = OpenStudio::Point3dVector.new
    vtx << mini_ceiling_vtx[1]
    vtx << mini_floor_vtx[2]
    vtx << mini_floor_vtx[1]
    vtx << mini_ceiling_vtx[2]
    well_north = OpenStudio::Model::Surface.new(vtx, model)
    well_north.setName("Well north")
    expect(well_north.setSpace(attic)).to be(true)

    vtx = OpenStudio::Point3dVector.new
    vtx << mini_ceiling_vtx[0]
    vtx << mini_floor_vtx[3]
    vtx << mini_floor_vtx[2]
    vtx << mini_ceiling_vtx[1]
    well_east = OpenStudio::Model::Surface.new(vtx, model)
    well_east.setName("Well east")
    expect(well_east.setSpace(attic)).to be(true)

    vtx = OpenStudio::Point3dVector.new
    vtx << mini_ceiling_vtx[3]
    vtx << mini_floor_vtx[0]
    vtx << mini_floor_vtx[3]
    vtx << mini_ceiling_vtx[0]
    well_south = OpenStudio::Model::Surface.new(vtx, model)
    well_south.setName("Well south")
    expect(well_south.setSpace(attic)).to be(true)

    vtx = OpenStudio::Point3dVector.new
    vtx << mini_ceiling_vtx[2]
    vtx << mini_floor_vtx[1]
    vtx << mini_floor_vtx[0]
    vtx << mini_ceiling_vtx[3]
    well_west = OpenStudio::Model::Surface.new(vtx, model)
    well_west.setName("Well west")
    expect(well_west.setSpace(attic)).to be(true)

    expect(mini_north.setAdjacentSurface(well_south)).to be(true)
    expect(mini_east.setAdjacentSurface(well_west)).to be(true)
    expect(mini_south.setAdjacentSurface(well_north)).to be(true)
    expect(mini_west.setAdjacentSurface(well_east)).to be(true)
    expect(mini_north.outsideBoundaryCondition).to eq("Surface")
    expect(mini_east.outsideBoundaryCondition).to eq("Surface")
    expect(mini_south.outsideBoundaryCondition).to eq("Surface")
    expect(mini_west.outsideBoundaryCondition).to eq("Surface")
    expect(well_south.outsideBoundaryCondition).to eq("Surface")
    expect(well_west.outsideBoundaryCondition).to eq("Surface")
    expect(well_south.outsideBoundaryCondition).to eq("Surface")
    expect(well_east.outsideBoundaryCondition).to eq("Surface")
    expect(mini_north.adjacentSurface.empty?).to be(false)
    expect(mini_east.adjacentSurface.empty?).to be(false)
    expect(mini_south.adjacentSurface.empty?).to be(false)
    expect(mini_west.adjacentSurface.empty?).to be(false)
    expect(well_south.adjacentSurface.empty?).to be(false)
    expect(well_west.adjacentSurface.empty?).to be(false)
    expect(well_north.adjacentSurface.empty?).to be(false)
    expect(well_east.adjacentSurface.empty?).to be(false)
    expect(mini_north.adjacentSurface.get).to eq(well_south)
    expect(mini_east.adjacentSurface.get).to eq(well_west)
    expect(mini_south.adjacentSurface.get).to eq(well_north)
    expect(mini_west.adjacentSurface.get).to eq(well_east)
    expect(well_south.adjacentSurface.get).to eq(mini_north)
    expect(well_west.adjacentSurface.get).to eq(mini_east)
    expect(well_north.adjacentSurface.get).to eq(mini_south)
    expect(well_east.adjacentSurface.get).to eq(mini_west)

    # Re-validating pre-tested areas + volumes.
    expect(core.floorArea).to be_within(TOL).of(149.66 - 4)      # -mini m2
    core_volume = core.floorArea * core.ceilingHeight
    expect(core_volume).to be_within(TOL).of(core.volume)
    expect(attic.volume).to be_within(TOL).of(720.19 + 4 * 3.05) # +mini m3
    expect(attic.floorArea).to be_within(TOL).of(567.98)

    expect(mod1.poly(core_floor, true).empty?).to be(true)   # now concave
    expect(mod1.poly(core_ceiling, true).empty?).to be(true) # now concave
    expect(mod1.poly(attic_floor, true).empty?).to be(true)  # now concave
    expect(mod1.logs.size).to eq(3)
    expect(mod1.error?).to be(true)
    mod1.logs.each {|l| expect(l[:message].include?("non-convex")).to be(true)}
    expect(mod1.clean!).to eq(DBG)

    file = File.join(__dir__, "files/osms/out/mini3.osm")
    model.save(file, true)
    # Simulation results E+ 22.2 (SutherlandHodgman, PolygonClipping)
    # ... no E+ errors/warnings.
    #
    # mini2.osm A  FullInteriorAndExterior                 252 GJ 3.5 UMH cool
    # mini2.osm B  FullExteriorWithReflections             253 GJ 3.5 UMH cool
    # mini2.osm C  FullInteriorAndExteriorWithReflections  253 GJ 3.5 UMH cool
  end

  it "checks generated skylight wells" do
    expect(mod1.reset(DBG)).to eq(DBG)
    expect(mod1.level).to eq(DBG)
    expect(mod1.clean!).to eq(DBG)

    translator = OpenStudio::OSVersion::VersionTranslator.new
    v = OpenStudio.openStudioVersion.split(".").join.to_i
    file = File.join(__dir__, "files/osms/in/smalloffice.osm")
    path = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model.empty?).to be(false)
    model = model.get

    # The following tests are a step-by-step, proof of concept demo towards an
    # eventual general solution to autogenerate skylight wells, roof monitors,
    # dormers, etc., in particular when spanning unoccupied spaces like attics
    # and plenums. Once the final set of methods are completed and validated,
    # these current tests may or may not be maintained in the long run (in
    # favour of more compact, to-the-point tests).

    # Test case: Add 2x skylights to the sloped "Attic_roof_north", with a
    # single individual wels leading down to "Core_ZN". Each (sloped) skylight
    # is a standard 4'x4' model (1.2m x 1.2m), with a 1m gap between skylights,
    # and 200mm from the roof ridge.

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # 1. Fetch attic space and north-facing roof surface.
    attic = model.getSpaceByName("Attic")
    expect(attic.empty?).to be(false)
    attic = attic.get

    roof = model.getSurfaceByName("Attic_roof_north")
    expect(roof.empty?).to be(false)
    roof = roof.get

    core = model.getSpaceByName("Core_ZN")
    expect(core.empty?).to be(false)
    core = core.get

    plafond = model.getSurfaceByName("Perimeter_ZN_1_ceiling")
    expect(plafond.empty?).to be(false)
    plafond = plafond.get

    ceiling = model.getSurfaceByName("Core_ZN_ceiling")
    expect(ceiling.empty?).to be(false)
    ceiling = ceiling.get

    minZ = ceiling.vertices.map(&:z).min
    maxZ = ceiling.vertices.map(&:z).max
    expect(minZ).to be_within(TOL).of(maxZ)
    expect(plafond.vertices.map(&:z).min).to be_within(TOL).of(minZ)
    expect(plafond.vertices.map(&:z).max).to be_within(TOL).of(maxZ)

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # 2. Generate an array of 2x skylights to North Roof.
    #      __________
    #     /  || ||   \
    #    /            \
    #   /              \
    #  /                \
    # /__________________\

    side   = 1.2
    offset = side + 1
    head   = mod1.height(roof.vertices) - 0.2
    expect(head).to be_within(TOL).of(10.16)

    sub = {}
    sub[:id    ] = "North Skylight"
    sub[:type  ] = "Skylight"
    sub[:height] = side
    sub[:width ] = side
    sub[:head  ] = head
    sub[:count ] = 2
    sub[:offset] = offset
    expect(mod1.addSubs(model, roof, [sub])).to be(true)
    expect(mod1.status.zero?).to be(true)
    expect(mod1.logs.size.zero?).to be(true)
    expect(roof.subSurfaces.size).to eq(2)
    plane = roof.plane
    subs  = roof.subSurfaces
    expect(subs.size).to eq(2)

    subs.each { |sub| expect(sub.plane.equal(plane)).to be(true) }

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # 3. Generate a 'buffered' outline around both skylights. The upper edge
    # of the outline coincides with the roof ridge. The outline is to define a
    # new Core_ZN ceiling holding the 2x new skylights.
    #      __________
    #     /  |___|   \
    #    /            \
    #   /              \
    #  /                \
    # /__________________\

    perimetre = mod1.outline(subs, 0.200)
    expect(perimetre.is_a?(OpenStudio::Point3dVector)).to be(true)
    expect(mod1.fits?(perimetre, roof)).to be(true)

    # Generate a projected 'perimetre' unto the original horizontal core
    # ceiling below. Ensure 'opening' "fits" - a "sine qua non" condition for
    # an eventual general method: a generated 'outline' must neatly fit within
    # a receiving surface (below). A reminder: "fits?" ensures candidate
    # polygons share the same 3D plane, yet will emit a warning if the 2nd
    # polygon doesn't initially share the same plane as the 1st one. One can
    # alternatively pre-flatten the 'opening' to avoid the warning.
    expect(mod1.fits?(perimetre, ceiling)).to be(true)
    expect(mod1.warn?).to be(true)
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message].include?(" (non-aligned)")).to be(true)
    expect(mod1.clean!).to eq(DBG)
    opening = mod1.flatten(perimetre, :z, minZ)
    expect(mod1.fits?(opening, ceiling)).to be(true)
    expect(mod1.status.zero?).to be(true)

    # Polygons below appended with an 'a' designate 'aligned' (or flattened)
    # polygons relying on OpenStudio::Transformation class.
    t     = OpenStudio::Transformation.alignFace(roof.vertices)
    aroof = mod1.poly(roof,     false, true, false, true, :cw)
    aperi = mod1.poly(perimetre, true, true, false,    t, :cw)
    expect(mod1.clockwise?(aroof)).to be(true)
    expect(mod1.clockwise?(aperi)).to be(true)
    expect(mod1.status.zero?).to be(true)
    expect(mod1.fits?(aperi, aroof)).to be(true)
    expect(mod1.status.zero?).to be(true)

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # 4. Create a new, clockwise bounding box around aroof.
    #  ___ __________ ___
    # |   /          \   |
    # |  /            \  |
    # | /              \ |
    # |/                \|
    # /__________________\

    abox = mod1.outline([aroof])
    expect(mod1.status.zero?).to be(true)
    expect(mod1.width(aperi)).to be < mod1.width(abox)

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # 5. Create a new, clockwise bounding box 'strip' around aperi (i.e. the
    # new, flattened sub surface base surface), yet stretched left & right as
    # to align with the roof bounding 'box' X-axis coordinates.
    #  ___ __________ ___
    # |___/__ ___ ___\___|
    # |  /            \  |
    # | /              \ |
    # |/                \|
    # /__________________\

    xMIN = abox.min_by(&:x).x
    xMAX = abox.max_by(&:x).x
    yMIN = aperi.min_by(&:y).y
    yMAX = aperi.max_by(&:y).y

    astrip = OpenStudio::Point3dVector.new
    astrip << OpenStudio::Point3d.new(xMAX, yMAX, 0)
    astrip << OpenStudio::Point3d.new(xMAX, yMIN, 0)
    astrip << OpenStudio::Point3d.new(xMIN, yMIN, 0)
    astrip << OpenStudio::Point3d.new(xMIN, yMAX, 0)
    # puts astrip
    # [28.89, 10.36, 0]
    # [28.89,  8.76, 0]
    # [ 0.00,  8.76, 0]
    # [ 0.00, 10.36, 0]

    # Split box by intersecting with strip.
    res1 = OpenStudio.intersect(astrip, abox, TOL)
    expect(res1.empty?).to be(false)
    res1 = res1.get
    # puts res1.polygon1 # ... == res1.polygon2 (strip)
    # [28.89,  8.76, 0]
    # [ 0.00,  8.76, 0]
    # [ 0.00, 10.36, 0]
    # [28.89, 10.36, 0]

    # The 'strip' isn't chopped up, so no residual polygons. The initial 'box'
    # is however split into 2x (possibly 3x in other cases):
    #   1. the intersecting strip itself
    #   2. a residual, non-intersecting 'box' (smaller than the initial one)
    expect(res1.newPolygons1.empty?).to be(true)
    expect(res1.newPolygons2.size).to eq(1)
    # res1.newPolygons2.each { |poly, i| puts poly }
    # [28.89, 8.76, 0]
    # [28.89, 0.00, 0]
    # [ 0.00, 0.00, 0]
    # [ 0.00, 8.76, 0]

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # 6. Generate a new array to hold (here 3x, possibly 4x in other cases)
    # new, flattened roof polygons that will replace the initial, single aroof
    # polygon.
    aroofs = []

    # The first of these new aroofs is the intersection between the previous
    # residual box and the initial aroof.
    #  ___ __________ ___
    # |___/____o_ ___\___|
    # |  /            \  |
    # | /      x       \ |
    # |/                \|
    # /__________________\

    res2 = OpenStudio.intersect(res1.newPolygons2.first, aroof, TOL)
    expect(res2.empty?).to be(false)
    res2 = res2.get
    # puts res2.polygon1 # ... res2.polygon2 ('x' marks the spot)
    # [28.89, 0.00, 0]
    # [ 0.00, 0.00, 0]
    # [ 8.31, 8.76, 0]
    # [20.58, 8.76, 0]
    aroofs << mod1.to_p3Dv(res2.polygon1)

    expect(res2.newPolygons1.size).to eq(2) # 2x triangles left/right of 'x'
    expect(res2.newPolygons2.size).to eq(1) # previous residual 'o'

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # 7. Repeat similar intersection exercice between aperi ('a') vs 'o'.
    #      __________
    #     /_o|_a_|o__\
    #    /            \
    #   /              \
    #  /                \
    # /__________________\

    # puts aperi
    # [16.35, 10.36, 0]
    # [16.35,  8.76, 0]
    # [12.55,  8.76, 0]
    # [12.55, 10.36, 0]
    res3 = OpenStudio.intersect(res2.newPolygons2.first, aperi, TOL)
    expect(res3.empty?).to be(false)
    res3 = res3.get
    # puts res3.polygon1 # ... res3.polygon2 (i.e. aperi)
    # [16.35,  8.76, 0]
    # [12.55,  8.76, 0]
    # [12.55, 10.36, 0]
    # [16.35, 10.36, 0]

    expect(res3.newPolygons1.size).to eq(2) # 2x polygons, left/right of 'o'
    expect(res3.newPolygons2.empty?).to be(true) # aperi remains intact
    # res3.newPolygons1.each { |poly| puts poly }
    # [12.55,  8.76, 0]
    # [ 8.31,  8.76, 0]
    # [ 9.83, 10.36, 0]
    # [12.55, 10.36, 0]
    #
    # [16.35,  8.76, 0]
    # [16.35, 10.36, 0]
    # [19.06, 10.36, 0]
    # [20.58,  8.76, 0]
    res3.newPolygons1.each { |poly| aroofs << mod1.to_p3Dv(poly) }
    expect(aroofs.size).to eq(3)

    # Area check.
    areas = 0

    aroofs.each do |poly|
      area = OpenStudio.getArea(poly)
      expect(area.empty?).to be(false)
      areas += area.get
    end

    area = OpenStudio.getArea(aperi)
    expect(area.empty?).to be(false)
    areas += area.get
    expect((roof.grossArea - areas).abs).to be < TOL

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # Temporary setup for testing:
    #   1. Generate new 'skybase' for the skylights, with 'perimetre' vertices.
    #      Apply non-defaulted roof parameters. Transfer skylights to skybase.
    skybase = OpenStudio::Model::Surface.new(perimetre, model)
    skybase.setName("#{roof.nameString} | skybase")
    expect(skybase.setSpace(attic)).to be(true)

    unless roof.isConstructionDefaulted
      construction = roof.construction
      expect(construction.empty?).to be(false)
      construction = construction.get.to_LayeredConstruction
      expect(construction.empty?).to be(false)
      construction = construction.get
      expect(skybase.setConstruction(construction)).to be(true)
    end

    expect(roof.subSurfaces.size).to eq(2)
    expect(skybase.subSurfaces.empty?).to be(true)
    subs.each { |sub| expect(sub.setSurface(skybase)).to be(true) }
    expect(roof.subSurfaces.empty?).to be(true)
    expect(skybase.subSurfaces.size).to eq(2)

    #   2. Modify initial roof vertices with the 1° new polygon (redressed).
    poly1 = mod1.to_p3Dv(t * mod1.ulc(aroofs.first))
    expect(poly1.is_a?(OpenStudio::Point3dVector)).to be(true)
    # puts poly1
    # [19.98, 10.75, 5.82]
    # [28.29, 19.06, 3.05]
    # [-0.60, 19.06, 3.05]
    # [ 7.71, 10.75, 5.82]
    expect(roof.setVertices(poly1)).to be(true)

    #   3. Add subsequent generated roof polygons (also redressed).
    aroofs.each_with_index do |poly, i|
      next if i == 0

      vtx = mod1.to_p3Dv(t * mod1.ulc(poly))
      surface = roof.clone
      surface = surface.to_Surface
      expect(surface.empty?).to be(false)
      surface = surface.get
      expect(surface.setVertices(vtx)).to be(true)
    end

    file = File.join(__dir__, "files/osms/out/office.osm")
    model.save(file, true)
  end

  it "checks facet retrieval" do
    expect(mod1.reset(DBG)).to eq(DBG)
    expect(mod1.level).to eq(DBG)
    expect(mod1.clean!).to eq(DBG)

    translator = OpenStudio::OSVersion::VersionTranslator.new
    file = File.join(__dir__, "files/osms/out/seb_ext2.osm")
    path = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model.empty?).to be(false)
    model = model.get
    spaces = model.getSpaces

    # The solution is similar to:
    #   OpenStudio::Model::Space::findSurfaces(minDegreesFromNorth,
    #                                          maxDegreesFromNorth,
    #                                          minDegreesTilt,
    #                                          maxDegreesTilt,
    #                                          tol)
    #   https://s3.amazonaws.com/openstudio-sdk-documentation/cpp/
    #   OpenStudio-3.6.1-doc/model/html/classopenstudio_1_1model_1_1_space.html
    #   #a0cf3c265ac314c1c846ee4962e852a3e
    #
    # ... yet it offers filters such as surface type and boundary conditions.
    northsouth = mod1.facets(spaces, "Outdoors", "Wall", [:north, :south])
    expect(northsouth.size).to eq(0)

    north = mod1.facets(spaces, "Outdoors", "Wall", [:north])
    expect(north.size).to eq(14)

    northeast = mod1.facets(spaces, "Outdoors", "Wall", [:north, :east])
    expect(northeast.size).to eq(8)

    floors = mod1.facets(spaces, "Ground", "Floor", [:bottom])
    expect(floors.size).to eq(4)

    roofs = mod1.facets(spaces, "Outdoors", "RoofCeiling", [:top])
    expect(roofs.size).to eq(5)
  end

  it "checks slab generation" do
    expect(mod1.reset(DBG)).to eq(DBG)
    expect(mod1.level).to eq(DBG)
    expect(mod1.clean!).to eq(DBG)

    model = OpenStudio::Model::Model.new

    x0 = 1
    y0 = 2
    z0 = 3
    w1 = 4
    w2 = w1 * 2
    d1 = 5
    d2 = d1 * 2

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # 1x valid 'floor' plate.
    #        ____
    #       |    |
    #       |    |
    #       |  1 |
    #       |____|
    #
    plates = []
    plates << {x: x0, y: y0, dx: w1, dy: d2} # bottom-left XY origin

    slab = mod1.genSlab(plates, z0)
    expect(mod1.status.zero?).to be(true)
    expect(slab.is_a?(OpenStudio::Point3dVector)).to be(true)
    expect(slab.size).to eq(4)

    surface = OpenStudio::Model::Surface.new(slab, model)
    expect(surface.is_a?(OpenStudio::Model::Surface)).to be(true)
    expect(surface.grossArea).to be_within(TOL).of(2 * 20)
    expect(surface.vertices.size).to eq(4)

    expect(surface.vertices[0].x).to be_within(TOL).of(x0 + w1)
    expect(surface.vertices[0].y).to be_within(TOL).of(y0 + d2)
    expect(surface.vertices[0].z).to be_within(TOL).of(z0)

    expect(surface.vertices[1].x).to be_within(TOL).of(x0 + w1)
    expect(surface.vertices[1].y).to be_within(TOL).of(y0)
    expect(surface.vertices[1].z).to be_within(TOL).of(z0)

    expect(surface.vertices[2].x).to be_within(TOL).of(x0)
    expect(surface.vertices[2].y).to be_within(TOL).of(y0)
    expect(surface.vertices[2].z).to be_within(TOL).of(z0)

    expect(surface.vertices[3].x).to be_within(TOL).of(x0)
    expect(surface.vertices[3].y).to be_within(TOL).of(y0 + d2)
    expect(surface.vertices[3].z).to be_within(TOL).of(z0)

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # 2x valid 'floor' plates.
    #        ____ ____
    #       |    |  2 |
    #       |    |____|
    #       |  1 |
    #       |____|
    #
    plates = []
    plates << {x: x0,      y: y0,      dx: w1, dy: d2}
    plates << {x: x0 + w1, y: y0 + d1, dx: w1, dy: d1}

    slab = mod1.genSlab(plates, z0)
    expect(mod1.status.zero?).to be(true)
    expect(slab.is_a?(OpenStudio::Point3dVector)).to be(true)
    expect(slab.size).to eq(6)

    surface = OpenStudio::Model::Surface.new(slab, model)
    expect(surface.is_a?(OpenStudio::Model::Surface)).to be(true)
    expect(surface.vertices.size).to eq(6)
    expect(surface.grossArea).to be_within(TOL).of(3 * 20)

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # 3x valid 'floor' plates.
    #        ____ ____
    #       |    |  2 |
    #   ____|    |____|
    #  |   3|  1 |
    #  |____|____|
    #
    plates = []
    plates << {x: x0,      y: y0,      dx: w1, dy: d2}
    plates << {x: x0 + w1, y: y0 + d1, dx: w1, dy: d1}
    plates << {x: x0 - w1, y: y0,      dx: w1, dy: d1} # X origin < 0

    slab = mod1.genSlab(plates, z0)
    expect(mod1.status.zero?).to be(true)
    expect(slab.is_a?(OpenStudio::Point3dVector)).to be(true)
    expect(slab.size).to eq(8)

    surface = OpenStudio::Model::Surface.new(slab, model)
    expect(surface.is_a?(OpenStudio::Model::Surface)).to be(true)
    expect(surface.vertices.size).to eq(8)
    expect(surface.grossArea).to be_within(TOL).of(4 * 20)

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # 3x 'floor' plates + 1x unconnected 'plate'.
    #        ____ ____   ____
    #       |    |  2 | |  4 |
    #   ____|    |____| |____|
    #  |   3|  1 |
    #  |____|____|
    #
    plates = []
    plates << {x: x0,          y: y0,      dx: w1, dy: d2} # index 0, #1
    plates << {x: x0 + w1,     y: y0 + d1, dx: w1, dy: d1} # index 1, #2
    plates << {x: x0 - w1,     y: y0,      dx: w1, dy: d1} # index 2, #3
    plates << {x: x0 + w2 + 1, y: y0 + d1, dx: w1, dy: d1} # index 3, #4

    slab = mod1.genSlab(plates, z0)
    expect(mod1.error?).to be(true)
    msg = mod1.logs.first[:message]
    expect(msg).to eq("Invalid 'plate # 4 (index 3)' (OSut::genSlab)")
    expect(mod1.clean!).to eq(DBG)
    expect(slab.is_a?(OpenStudio::Point3dVector)).to be(true)
    expect(slab.empty?).to be(true)

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # 3x 'floor' plates + 1x overlapping 'plate'.
    #        ____ ____
    #       |    |  2 |__
    #   ____|    |____| 4|
    #  |   3|  1 |  |____|
    #  |____|____|
    #
    plates = []
    plates << {x: x0,          y: y0,      dx: w1, dy: d2}
    plates << {x: x0 + w1,     y: y0 + d1, dx: w1, dy: d1}
    plates << {x: x0 - w1,     y: y0,      dx: w1, dy: d1}
    plates << {x: x0 + w2 - 1, y: y0 + 1,  dx: w1, dy: d1}

    slab = mod1.genSlab(plates, z0)
    puts mod1.logs
    expect(mod1.status.zero?).to be(true)
    expect(slab.is_a?(OpenStudio::Point3dVector)).to be(true)
    expect(slab.size).to eq(12)

    surface = OpenStudio::Model::Surface.new(slab, model)
    expect(surface.is_a?(OpenStudio::Model::Surface)).to be(true)
    expect(surface.vertices.size).to eq(12)
    expect(surface.grossArea).to be_within(TOL).of(5 * 20 - 1)

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # Same as previous, yet overlapping 'plate' has a negative dX while X
    # origin is set at right (not left) corner.
    #        ____ ____
    #       |    |  2 |__
    #   ____|    |____| 4|
    #  |   3|  1 |  |____|
    #  |____|____|
    #
    plates = []
    plates << {x: x0,              y: y0,      dx:  w1, dy: d2}
    plates << {x: x0 + w1,         y: y0 + d1, dx:  w1, dy: d1}
    plates << {x: x0 - w1,         y: y0,      dx:  w1, dy: d1}
    plates << {x: x0 + 3 * w1 - 1, y: y0 + 1,  dx: -w1, dy: d1}

    slab = mod1.genSlab(plates, z0)
    puts mod1.logs
    expect(mod1.status.zero?).to be(true)
    expect(slab.is_a?(OpenStudio::Point3dVector)).to be(true)
    expect(slab.size).to eq(12)

    surface = OpenStudio::Model::Surface.new(slab, model)
    expect(surface.is_a?(OpenStudio::Model::Surface)).to be(true)
    expect(surface.vertices.size).to eq(12)
    expect(surface.grossArea).to be_within(TOL).of(5 * 20 - 1)

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # Same as previous, yet overlapping 'plate' has both negative dX & dY,
    # while XY origin is set at top-right (not bottom-left) corner.
    #        ____ ____
    #       |    |  2 |__
    #   ____|    |____| 4|
    #  |   3|  1 |  |____|
    #  |____|____|
    #
    plates = []
    plates << {x: x0,              y: y0,           dx:  w1, dy:  d2}
    plates << {x: x0 + w1,         y: y0 + d1,      dx:  w1, dy:  d1}
    plates << {x: x0 - w1,         y: y0,           dx:  w1, dy:  d1}
    plates << {x: x0 + 3 * w1 - 1, y: y0 + 1 + d1,  dx: -w1, dy: -d1}

    slab = mod1.genSlab(plates, z0)
    puts mod1.logs
    expect(mod1.status.zero?).to be(true)
    expect(slab.is_a?(OpenStudio::Point3dVector)).to be(true)
    expect(slab.size).to eq(12)

    surface = OpenStudio::Model::Surface.new(slab, model)
    expect(surface.is_a?(OpenStudio::Model::Surface)).to be(true)
    expect(surface.vertices.size).to eq(12)
    expect(surface.grossArea).to be_within(TOL).of(5 * 20 - 1)
  end
end
