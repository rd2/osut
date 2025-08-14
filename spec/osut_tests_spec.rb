require "osut"

RSpec.describe OSut do
  TOL  = OSut::TOL.dup
  TOL2 = OSut::TOL2.dup
  DBG  = OSut::DEBUG.dup
  INF  = OSut::INFO.dup
  WRN  = OSut::WARN.dup
  ERR  = OSut::ERR.dup
  FTL  = OSut::FATAL.dup
  HEAD = OSut::HEAD.dup
  SILL = OSut::SILL.dup

  let(:cls1) { Class.new  { extend OSut } }
  let(:cls2) { Class.new  { extend OSut } }
  let(:mod1) { Module.new { extend OSut } }

  it "checks generated constructions" do
    expect(cls1.level).to eq(INF)
    expect(cls1.reset(DBG)).to eq(DBG)
    expect(cls1.level).to eq(DBG)
    expect(cls1.clean!).to eq(DBG)

    mass  = cls1.class_variable_get(:@@mass)
    mats  = cls1.class_variable_get(:@@mats)
    film  = cls1.class_variable_get(:@@film)
    uo    = cls1.class_variable_get(:@@uo)
    model = OpenStudio::Model::Model.new
    uo1   = 2.140
    uo2   = 0.214
    uo3   = 3.566
    uo4   = 4.812
    uo5   = 3.765
    uo6   = 3.698
    uo7   = 4.244
    uo8   = uo[:door]
    uo9   = 0.900

    # Typical uninsulated, framed cavity wall, suitable for light interzone
    # assemblies (i.e. symmetrical, 3-layer construction).
    specs   = {type: :partition}
    surface = cls1.genConstruction(model, specs)
    expect(surface).to_not be_nil
    expect(surface).to be_a(OpenStudio::Model::LayeredConstruction)
    expect(surface.layers.size).to eq(3)
    u = 1 / cls1.rsi(surface, film[:partition])
    expect(u).to be_within(TOL).of(uo1)
    expect(surface.layers.first).to eq(surface.layers.last)

    # An alternative to (uninsulated) :partition (+inputs, same outcome).
    specs   = {type: :wall, clad: :none, uo: nil}
    surface = cls1.genConstruction(model, specs)
    expect(surface).to_not be_nil
    expect(surface).to be_a(OpenStudio::Model::LayeredConstruction)
    expect(surface.layers.size).to eq(3)
    u = 1 / cls1.rsi(surface, film[:wall])
    expect(u).to be_within(TOL).of(uo1)
    expect(surface.layers.first).to eq(surface.layers.last)

    # Insulated :partition variant.
    specs   = {type: :partition, uo: uo2}
    surface = cls1.genConstruction(model, specs)
    expect(surface).to_not be_nil
    expect(surface).to be_a(OpenStudio::Model::LayeredConstruction)
    expect(surface.layers.size).to eq(3)
    u = 1 / cls1.rsi(surface, film[:partition])
    expect(u).to be_within(TOL).of(uo2)
    expect(surface.layers.first).to eq(surface.layers.last)

    # An alternative to (insulated) :partition (+inputs, same outcome).
    specs   = {type: :wall, uo: uo2, clad: :none}
    surface = cls1.genConstruction(model, specs)
    expect(surface).to_not be_nil
    expect(surface).to be_a(OpenStudio::Model::LayeredConstruction)
    expect(surface.layers.size).to eq(3)
    u = 1 / cls1.rsi(surface, film[:wall])
    expect(u).to be_within(TOL).of(uo2)
    expect(surface.layers.first).to eq(surface.layers.last)

    # A wall inherits a 4th (cladding) layer, by default.
    specs   = {type: :wall, uo: uo2}
    surface = cls1.genConstruction(model, specs)
    expect(surface).to_not be_nil
    expect(surface).to be_a(OpenStudio::Model::LayeredConstruction)
    expect(surface.layers.size).to eq(4)
    u = 1 / cls1.rsi(surface, film[:wall])
    expect(u).to be_within(TOL).of(uo2)
    expect(surface.layers.first).to_not eq(surface.layers.last)

    # Otherwise, a wall has a minimum of 2 layers.
    specs   = {type: :wall, uo: uo2, clad: :none, finish: :none}
    surface = cls1.genConstruction(model, specs)
    expect(surface).to_not be_nil
    expect(surface).to be_a(OpenStudio::Model::LayeredConstruction)
    expect(surface.layers.size).to eq(2)
    u = 1 / cls1.rsi(surface, film[:wall])
    expect(u).to be_within(TOL).of(uo2)
    expect(surface.layers.first).to_not eq(surface.layers.last)

    # Default shading material.
    specs   = {type: :shading}
    surface = cls1.genConstruction(model, specs)
    expect(surface).to_not be_nil
    expect(surface).to be_a(OpenStudio::Model::LayeredConstruction)
    expect(surface.layers.size).to eq(1)
    expect(surface.layers.first.nameString).to eq("OSut|material|015")

    # A single-layered, uninsulated e.g. 5/8" :partition (alternative :shading).
    specs   = {type: :partition, clad: :none, finish: :none}
    surface = cls1.genConstruction(model, specs)
    expect(surface).to_not be_nil
    expect(surface).to be_a(OpenStudio::Model::LayeredConstruction)
    expect(surface.layers.size).to eq(1)
    u = 1 / cls1.rsi(surface, film[:wall])
    expect(u).to be_within(TOL).of(uo3)
    expect(surface.layers.first.nameString).to eq("OSut|material|015")

    # A single-layered, uninsulated e.g. 4" concrete :partition.
    specs   = {type: :partition, clad: :none, finish: :none, frame: :medium}
    surface = cls1.genConstruction(model, specs)
    expect(surface).to_not be_nil
    expect(surface).to be_a(OpenStudio::Model::LayeredConstruction)
    expect(surface.layers.size).to eq(1)
    u = 1 / cls1.rsi(surface, film[:wall])
    expect(u).to be_within(TOL).of(uo4)
    expect(surface.layers.first.nameString).to eq("OSut|concrete|100")

    # A single-layered, uninsulated e.g. 8" concrete :partition.
    specs   = {type: :partition, clad: :none, finish: :none, frame: :heavy}
    surface = cls1.genConstruction(model, specs)
    expect(surface).to_not be_nil
    expect(surface).to be_a(OpenStudio::Model::LayeredConstruction)
    expect(surface.layers.size).to eq(1)
    u = 1 / cls1.rsi(surface, film[:wall])
    expect(u).to be_within(TOL).of(uo5)
    expect(surface.layers.first.nameString).to eq("OSut|concrete|200")

    # A light (minimal, 1x layer), uninsulated attic roof (alternative: shading).
    specs   = {type: :roof, uo: nil, clad: :none, finish: :none}
    surface = cls1.genConstruction(model, specs)
    expect(surface).to_not be_nil
    expect(surface).to be_a(OpenStudio::Model::LayeredConstruction)
    expect(surface.layers.size).to eq(1)
    u = 1 / cls1.rsi(surface, film[:roof])
    expect(u).to be_within(TOL).of(uo6)

    # Insulated, cathredral ceiling construction (alternative :shading).
    specs   = {type: :roof, uo: uo2}
    surface = cls1.genConstruction(model, specs)
    expect(surface).to_not be_nil
    expect(surface).to be_a(OpenStudio::Model::LayeredConstruction)
    expect(surface.layers.size).to eq(3)
    u = 1 / cls1.rsi(surface, film[:roof])
    expect(u).to be_within(TOL).of(uo2)

    # Insulated, unfinished outdoor-facing plenum roof (polyiso above 4" slab).
    specs   = {type: :roof, uo: uo2, frame: :medium, finish: :medium}
    surface = cls1.genConstruction(model, specs)
    expect(surface).to_not be_nil
    expect(surface).to be_a(OpenStudio::Model::LayeredConstruction)
    expect(surface.layers.size).to eq(3)
    u = 1 / cls1.rsi(surface, film[:roof])
    expect(u).to be_within(TOL).of(uo2)
    expect(surface.layers[1].nameString).to eq("OSut|polyiso|108")
    expect(surface.layers[2].nameString).to eq("OSut|concrete|100")

    # Roof above conditioned parking garage (polyiso under 8" slab).
    specs   = {type: :roof, uo: uo2, clad: :heavy, frame: :medium, finish: :none}
    surface = cls1.genConstruction(model, specs)
    expect(surface).to_not be_nil
    expect(surface).to be_a(OpenStudio::Model::LayeredConstruction)
    expect(surface.layers.size).to eq(2)
    u = 1 / cls1.rsi(surface, film[:roof])
    expect(u).to be_within(TOL).of(uo2)
    expect(surface.layers[0].nameString).to eq("OSut|concrete|200")
    expect(surface.layers[1].nameString).to eq("OSut|polyiso|110")

    # Uninsulated plenum ceiling tiles (alternative :shading).
    specs   = {type: :roof, uo: nil, clad: :none, finish: :none}
    surface = cls1.genConstruction(model, specs)
    expect(surface).to_not be_nil
    expect(surface).to be_a(OpenStudio::Model::LayeredConstruction)
    expect(surface.layers.size).to eq(1)
    u = 1 / cls1.rsi(surface, film[:roof])
    expect(u).to be_within(TOL).of(uo6)

    # Unfinished, insulated, framed attic floor (blown cellulose).
    specs   = {type: :floor, uo: uo2, frame: :heavy, finish: :none}
    surface = cls1.genConstruction(model, specs)
    expect(surface).to_not be_nil
    expect(surface).to be_a(OpenStudio::Model::LayeredConstruction)
    expect(surface.layers.size).to eq(2)
    u = 1 / cls1.rsi(surface, film[:floor])
    expect(u).to be_within(TOL).of(uo2)
    expect(surface.layers[1].nameString).to eq("OSut|cellulose|217")

    # Finished, insulated exposed floor (e.g. wood-framed, residential).
    specs   = {type: :floor, uo: uo2}
    surface = cls1.genConstruction(model, specs)
    expect(surface).to_not be_nil
    expect(surface).to be_a(OpenStudio::Model::LayeredConstruction)
    expect(surface.layers.size).to eq(3)
    u = 1 / cls1.rsi(surface, film[:floor])
    expect(u).to be_within(TOL).of(uo2)
    expect(surface.layers[1].nameString).to eq("OSut|mineral|211")

    # Finished, insulated exposed floor (e.g. 4" slab, steel web joists).
    specs   = {type: :floor, uo: uo2, finish: :medium}
    surface = cls1.genConstruction(model, specs)
    expect(surface).to_not be_nil
    expect(surface).to be_a(OpenStudio::Model::LayeredConstruction)
    expect(surface.layers.size).to eq(3)
    u = 1 / cls1.rsi(surface, film[:floor])
    expect(u).to be_within(TOL).of(uo2)
    expect(surface.layers[1].nameString).to eq("OSut|mineral|214")
    expect(surface.layers[2].nameString).to eq("OSut|concrete|100")

    # Uninsulated slab-on-grade.
    specs   = {type: :slab, frame: :none, finish: :none}
    surface = cls1::genConstruction(model, specs)
    expect(surface).to_not be_nil
    expect(surface).to be_a(OpenStudio::Model::LayeredConstruction)
    expect(surface.layers.size).to eq(2)
    expect(surface.layers[0].nameString).to eq("OSut|sand|100")
    expect(surface.layers[1].nameString).to eq("OSut|concrete|100")

    # Insulated slab-on-grade.
    specs   = {type: :slab, uo: uo2, finish: :none}
    surface = cls1::genConstruction(model, specs)
    expect(surface).to_not be_nil
    expect(surface).to be_a(OpenStudio::Model::LayeredConstruction)
    expect(surface.layers.size).to eq(3)
    u = 1 / cls1::rsi(surface, film[:slab])
    expect(u).to be_within(TOL).of(uo2)
    expect(surface.layers[0].nameString).to eq("OSut|sand|100")
    expect(surface.layers[1].nameString).to eq("OSut|polyiso|109")
    expect(surface.layers[2].nameString).to eq("OSut|concrete|100")

    # 8" uninsulated basement wall.
    specs   = {type: :basement, clad: :none, finish: :none}
    surface = cls1::genConstruction(model, specs)
    expect(surface).to_not be_nil
    expect(surface).to be_a(OpenStudio::Model::LayeredConstruction)
    expect(surface.layers.size).to eq(1)
    u = 1 / cls1::rsi(surface, film[:basement])
    expect(surface.layers[0].nameString).to eq("OSut|concrete|200")
    expect(u).to be_within(TOL).of(uo7)

    # 8" interior-insulated, finished basement wall.
    specs   = {type: :basement, uo: 2 * uo2, clad: :none}
    surface = cls1::genConstruction(model, specs)
    expect(surface).to_not be_nil
    expect(surface).to be_a(OpenStudio::Model::LayeredConstruction)
    expect(surface.layers.size).to eq(3)
    u = 1 / cls1::rsi(surface, film[:basement])
    expect(u).to be_within(TOL).of(2 * uo2)
    expect(surface.layers[0].nameString).to eq("OSut|concrete|200")
    expect(surface.layers[1].nameString).to eq("OSut|mineral|100")
    expect(surface.layers[2].nameString).to eq("OSut|drywall|015")

    # Standard, insulated steel door (default Uo = 1.8 W/K•m).
    specs   = {type: :door}
    surface = cls1::genConstruction(model, specs)
    expect(surface).to_not be_nil
    expect(surface).to be_a(OpenStudio::Model::LayeredConstruction)
    expect(surface.layers.size).to eq(1)
    u = 1 / cls1::rsi(surface, film[:door])
    expect(u).to be_within(TOL).of(uo8)

    specs   = {type: :door, uo: uo9}
    surface = cls1::genConstruction(model, specs)
    expect(surface).to_not be_nil
    expect(surface).to be_a(OpenStudio::Model::LayeredConstruction)
    expect(surface.layers.size).to eq(1)
    u = 1 / cls1::rsi(surface, film[:door])
    expect(u).to be_within(TOL).of(uo9)

    specs   = {type: :window, uo: uo9}
    surface = cls1::genConstruction(model, specs)
    expect(surface).to_not be_nil
    expect(surface).to be_a(OpenStudio::Model::LayeredConstruction)
    expect(surface.layers.size).to eq(1)
    u = 1 / cls1::rsi(surface) # not necessary to specify film
    expect(u).to be_within(TOL).of(uo9)

    specs   = {type: :skylight, uo: uo9}
    surface = cls1::genConstruction(model, specs)
    expect(surface).to_not be_nil
    expect(surface).to be_a(OpenStudio::Model::LayeredConstruction)
    expect(surface.layers.size).to eq(1)
    u = 1 / cls1::rsi(surface)
    expect(u).to be_within(TOL).of(uo9)

    # Invalid Uo (here, skylights and windows inherit default Uo values)
    specs   = {type: :skylight, uo: nil}
    surface = cls1::genConstruction(model, specs)
    expect(surface).to be_a(OpenStudio::Model::LayeredConstruction)
    expect(surface.layers.size).to eq(1)
    u = 1 / cls1::rsi(surface)
    expect(u).to be_within(TOL).of(uo[:skylight])

    # Invalid Uo (here, Uo-adjustments are ignored altogether)
    specs   = {type: :wall, uo: nil}
    surface = cls1::genConstruction(model, specs)
    expect(surface).to be_a(OpenStudio::Model::LayeredConstruction)
    expect(surface.layers.size).to eq(4)
    u = 1 / cls1::rsi(surface)
    expect(u).to be_within(TOL).of(2.23) # not matching any defaults

    expect(cls1.status.zero?).to be true
  end

  it "checks internal mass" do
    expect(mod1.clean!).to eq(DBG)

    ratios   = { entrance: 0.1, lobby: 0.3, meeting: 1.0 }
    model    = OpenStudio::Model::Model.new
    entrance = OpenStudio::Model::Space.new(model)
    lobby    = OpenStudio::Model::Space.new(model)
    meeting  = OpenStudio::Model::Space.new(model)
    offices  = OpenStudio::Model::Space.new(model)

    entrance.setName("Entrance")
    lobby.setName(      "Lobby")
    meeting.setName(  "Meeting")
    offices.setName(  "Offices")

    model.getSpaces.each do |space|
      name  = space.nameString.downcase.to_sym
      ratio = nil
      ratio = ratios[name] if ratios.keys.include?(name)
      sps   = OpenStudio::Model::SpaceVector.new
      sps  << space
      ok    = mod1.genMass(sps, ratio) unless ratio.nil?
      ok    = mod1.genMass(sps)            if ratio.nil?
      expect(ok).to be true
      expect(mod1.status).to be_zero
    end

    construction = nil
    material     = nil

    model.getInternalMasss.each do |m|
      d = m.internalMassDefinition
      expect(d.designLevelCalculationMethod).to eq("SurfaceArea/Area")

      ratio = d.surfaceAreaperSpaceFloorArea
      expect(ratio).to_not be_empty
      ratio = ratio.get

      case ratio
      when 0.1
        expect(d.nameString).to eq("OSut|InternalMassDefinition|0.10")
        expect(m.nameString.downcase).to include("entrance")
      when 0.3
        expect(d.nameString).to eq("OSut|InternalMassDefinition|0.30")
        expect(m.nameString.downcase).to include("lobby")
      when 1.0
        expect(d.nameString).to eq("OSut|InternalMassDefinition|1.00")
        expect(m.nameString.downcase).to include("meeting")
      else
        expect(d.nameString).to eq("OSut|InternalMassDefinition|2.00")
        expect(ratio).to eq(2.0)
      end

      c = d.construction
      expect(c).to_not be_empty
      c = c.get.to_Construction
      expect(c).to_not be_empty
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
    version    = OpenStudio.openStudioVersion.split(".").join.to_i
    expect(cls1.clean!).to eq(DBG)

    # The v1.11.5 (2016) seb.osm, shipped with OpenStudio, holds (what would now
    # be considered as deprecated) a definition of plenum floors (i.e. ceiling
    # tiles) generating several warnings with more recent OpenStudio versions.
    file  = File.join(__dir__, "files/osms/in/seb.osm")
    path  = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model).to_not be_empty
    model = model.get

    # "Shading Surface 4" is overlapping with a plenum exterior wall.
    sh4 = model.getShadingSurfaceByName("Shading Surface 4")
    expect(sh4).to_not be_empty
    sh4 = sh4.get
    sh4.remove

    plenum = model.getSpaceByName("Level 0 Ceiling Plenum")
    expect(plenum).to_not be_empty
    plenum = plenum.get

    thzone = plenum.thermalZone
    expect(thzone).to_not be_empty
    thzone = thzone.get

    # Before the fix.
    unless version < 350
      expect(plenum.isEnclosedVolume).to be true
      expect(plenum.isVolumeDefaulted).to be true
      expect(plenum.isVolumeAutocalculated).to be true
    end

    if version > 350 && version < 370
      expect(plenum.volume.round(0)).to eq(234)
    else
      expect(plenum.volume.round(0)).to eq(0)
    end

    expect(thzone.isVolumeDefaulted).to be true
    expect(thzone.isVolumeAutocalculated).to be true
    expect(thzone.volume).to be_empty

    plenum.surfaces.each do |s|
      next if s.outsideBoundaryCondition.downcase == "outdoors"

      # If a SEB plenum surface isn't facing outdoors, it's 1 of 4 "floor"
      # surfaces (each facing a ceiling surface below).
      adj = s.adjacentSurface
      expect(adj).to_not be_empty
      adj = adj.get
      expect(adj.vertices.size).to eq(s.vertices.size)

      # Same vertex sequence? Should be in reverse order.
      adj.vertices.each_with_index do |vertex, i|
        expect(mod1.same?(vertex, s.vertices.at(i))).to be true
      end

      expect(adj.surfaceType).to eq("RoofCeiling")
      expect(s.surfaceType).to eq("RoofCeiling")
      expect(s.setSurfaceType("Floor")).to be true
      expect(s.setVertices(s.vertices.reverse)).to be true

      # Vertices now in reverse order.
      adj.vertices.reverse.each_with_index do |vertex, i|
        expect(mod1.same?(vertex, s.vertices.at(i))).to be true
      end
    end

    # After the fix.
    unless version < 350
      expect(plenum.isEnclosedVolume).to be true
      expect(plenum.isVolumeDefaulted).to be true
      expect(plenum.isVolumeAutocalculated).to be true
    end

    expect(plenum.volume.round(0)).to eq(50) # right answer
    expect(thzone.isVolumeDefaulted).to be true
    expect(thzone.isVolumeAutocalculated).to be true
    expect(thzone.volume).to be_empty

    file = File.join(__dir__, "files/osms/out/seb2.osm")
    model.save(file, true)
    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- end of cleanup   #

    m  = "OSut::thickness"
    m1 = "holds non-StandardOpaqueMaterial(s) (#{m})"

    model.getConstructions.each do |c|
      next if c.to_LayeredConstruction.empty?

      c  = c.to_LayeredConstruction.get
      id = c.nameString

      # OSut 'thickness' method can only process layered constructions
      # built up with standard opaque layers, which exclude:
      #
      #   - "Air Wall"-based construction
      #   - "Double pane"-based construction
      #
      # The method returns '0' in such cases, while logging ERROR messages.
      th = cls1.thickness(c)
      expect(th).to be_within(TOL).of(0) if id.include?("Air Wall")
      expect(th).to be_within(TOL).of(0) if id.include?("Double pane")
      next if id.include?("Air Wall")
      next if id.include?("Double pane")

      expect(th).to be > 0
    end

    cls1.logs.each { |l| expect(l[:message]).to include(m1) }

    expect(cls1.error?).to be true
    expect(cls2.error?).to be true
    cls2.clean!
    expect(cls1.status).to be_zero
    expect(cls1.logs).to be_empty

    model.getConstructions.each do |c|
      next if c.to_LayeredConstruction.empty?

      # No ERROR logging if skipping over invalid arguments to 'thickness'.
      c  = c.to_LayeredConstruction.get
      id = c.nameString
      next if id.include?("Air Wall")
      next if id.include?("Double pane")

      th = cls2.thickness(c)
      expect(th).to be > 0
    end

    expect(cls2.status).to be_zero
    expect(cls2.logs).to be_empty
    expect(cls1.status).to be_zero
    expect(cls1.logs).to be_empty
  end

  it "checks if a set holds a construction" do
    translator = OpenStudio::OSVersion::VersionTranslator.new
    expect(mod1.clean!).to eq(DBG)

    mdl   = OpenStudio::Model::Model.new
    file  = File.join(__dir__, "files/osms/in/5ZoneNoHVAC.osm")
    path  = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model).to_not be_empty
    model = model.get

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
    c   = model.getLayeredConstructionByName(n2)
    expect(set).to_not be_empty
    expect(c).to_not be_empty
    set = set.get
    c   = c.get

    # TRUE case: 'set' holds 'c' (exterior roofceiling construction)
    expect(mod1.holdsConstruction?(set, c, false, true, t1)).to be true
    expect(mod1.status).to be_zero

    # FALSE case: not ground construction
    expect(mod1.holdsConstruction?(set, c, true, true, t1)).to be false
    expect(mod1.status).to be_zero

    # INVALID case: arg #5 : nil (instead of surface type string)
    expect(mod1.holdsConstruction?(set, c, true, true, nil)).to be false
    expect(mod1.debug?).to be true
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m5)
    expect(mod1.clean!).to eq(DBG)

    # INVALID case: arg #5 : empty surface type string
    expect(mod1.holdsConstruction?(set, c, true, true, "")).to be false
    expect(mod1.debug?).to be true
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m5)
    expect(mod1.clean!).to eq(DBG)

    # INVALID case: arg #5 : c construction (instead of surface type string)
    expect(mod1.holdsConstruction?(set, c, true, true, c)).to be false
    expect(mod1.debug?).to be true
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m5)
    expect(mod1.clean!).to eq(DBG)

    # INVALID case: arg #1 : c construction (instead of surface type string)
    expect(mod1.holdsConstruction?(c, c, true, true, c)).to be false
    expect(mod1.debug?).to be true
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m1)
    expect(mod1.clean!).to eq(DBG)

    # INVALID case: arg #1 : model (instead of surface type string)
    expect(mod1.holdsConstruction?(mdl, c, true, true, t1)).to be false
    expect(mod1.debug?).to be true
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m6)
    expect(mod1.clean!).to eq(DBG)
  end

  it "retrieves a surface default construction set" do
    translator = OpenStudio::OSVersion::VersionTranslator.new
    expect(mod1.clean!).to eq(DBG)

    m = "construction not defaulted (OSut::defaultConstructionSet)"

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    file  = File.join(__dir__, "files/osms/in/5ZoneNoHVAC.osm")
    path  = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model).to_not be_empty
    model = model.get

    model.getSurfaces.each do |s|
      set = mod1.defaultConstructionSet(s)
      expect(set).to_not be_nil
      expect(mod1.status).to be_zero
    end

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    file  = File.join(__dir__, "files/osms/out/seb2.osm")
    path  = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model).to_not be_empty
    model = model.get
    expect(mod1.clean!).to eq(DBG)

    model.getSurfaces.each do |s|
      set = mod1.defaultConstructionSet(s)
      expect(set).to be_nil
      expect(mod1.error?).to be true

      mod1.logs.each { |l| expect(l[:message]).to include(m) }
    end
  end

  it "checks glazing airfilms" do
    translator = OpenStudio::OSVersion::VersionTranslator.new
    expect(mod1.clean!).to eq(DBG)

    file  = File.join(__dir__, "files/osms/out/seb2.osm")
    path  = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model).to_not be_empty
    model = model.get

    m  = "OSut::glazingAirFilmRSi"
    m1 = "Invalid 'usi' arg #1 (#{m})"
    m2 = "'usi' String? expecting Numeric (#{m})"
    m3 = "'usi' NilClass? expecting Numeric (#{m})"

    model.getConstructions.each do |c|
      next unless c.isFenestration

      expect(c.uFactor).to_not be_empty
      expect(c.uFactor.get).to be_a(Numeric)
      expect(mod1.glazingAirFilmRSi(c.uFactor.get)).to be_within(TOL).of(0.17)
      expect(mod1.status).to be_zero
    end

    expect(mod1.glazingAirFilmRSi(9.0)).to be_within(TOL).of(0.1216)
    expect(mod1.warn?).to be true
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m1)

    expect(mod1.clean!).to eq(DBG)
    expect(mod1.glazingAirFilmRSi("")).to be_within(TOL).of(0.1216)
    expect(mod1.debug?).to be true
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m2)

    expect(mod1.clean!).to eq(DBG)
    expect(mod1.glazingAirFilmRSi(nil)).to be_within(TOL).of(0.1216)
    expect(mod1.debug?).to be true
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
    expect(mod1.clean!).to eq(DBG)

    file  = File.join(__dir__, "files/osms/out/seb2.osm")
    path  = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model).to_not be_empty
    model = model.get

    m  = "OSut::rsi"
    m1 = "Invalid 'lc' arg #1 (#{m})"
    m2 = "Negative 'film' (#{m})"
    m3 = "'film' NilClass? expecting Numeric (#{m})"
    m4 = "Negative 'temp K' (#{m})"
    m5 = "'temp K' NilClass? expecting Numeric (#{m})"

    model.getSurfaces.each do |s|
      next unless s.isPartOfEnvelope

      lc = s.construction
      expect(lc).to_not be_empty
      lc = lc.get.to_LayeredConstruction
      expect(lc).to_not be_empty
      lc = lc.get

      if s.isGroundSurface # 4x slabs on grade in SEB model
        expect(s.filmResistance).to be_within(TOL).of(0.160)
        expect(mod1.rsi(lc, s.filmResistance)).to be_within(TOL).of(0.448)
        expect(mod1.status).to be_zero
      else
        if s.surfaceType == "Wall"
          expect(s.filmResistance).to be_within(TOL).of(0.150)
          expect(mod1.rsi(lc, s.filmResistance)).to be_within(TOL).of(2.616)
          expect(mod1.status).to be_zero
        else # RoofCeiling
          expect(s.filmResistance).to be_within(TOL).of(0.136)
          expect(mod1.rsi(lc, s.filmResistance)).to be_within(TOL).of(5.631)
          expect(mod1.status).to be_zero
        end
      end
    end

    expect(mod1.rsi("", 0.150)).to be_within(TOL).of(0)
    expect(mod1.debug?).to be true
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m1)

    expect(mod1.clean!).to eq(DBG)
    expect(mod1.rsi(nil, 0.150)).to be_within(TOL).of(0)
    expect(mod1.debug?).to be true
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m1)

    lc = model.getLayeredConstructionByName("SLAB-ON-GRADE-FLOOR")
    expect(lc).to_not be_empty
    lc = lc.get

    expect(mod1.clean!).to eq(DBG)
    expect(mod1.rsi(lc, -1)).to be_within(TOL).of(0)
    expect(mod1.error?).to be true
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m2)

    expect(mod1.clean!).to eq(DBG)
    expect(mod1.rsi(lc, nil)).to be_within(TOL).of(0)
    expect(mod1.debug?).to be true
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m3)

    expect(mod1.clean!).to eq(DBG)
    expect(mod1.rsi(lc, 0.150, -300)).to be_within(TOL).of(0)
    expect(mod1.error?).to be true
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m4)

    expect(mod1.clean!).to eq(DBG)
    expect(mod1.rsi(lc, 0.150, nil)).to be_within(TOL).of(0)
    expect(mod1.debug?).to be true
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m5)
  end

  it "checks (opaque) insulating layers within a layered construction" do
    translator = OpenStudio::OSVersion::VersionTranslator.new
    expect(mod1.clean!).to eq(DBG)

    file  = File.join(__dir__, "files/osms/out/seb2.osm")
    path  = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model).to_not be_empty
    model = model.get

    m   = "OSut::insulatingLayer"
    cl1 = OpenStudio::Model::Surface
    cl2 = OpenStudio::Model::LayeredConstruction
    n1  = "Entryway  Wall 1"
    m1  = "Invalid 'lc' arg #1 (#{m})"
    m2  = "'#{n1}' #{cl1}? expecting #{cl2} (#{m})"

    model.getLayeredConstructions.each do |lc|
      lyr = mod1.insulatingLayer(lc)
      expect(lyr).to be_a(Hash)
      expect(lyr).to have_key(:index)
      expect(lyr).to have_key(:type )
      expect(lyr).to have_key(:r)

      if lc.isFenestration
        expect(mod1.status).to be_zero
        expect(lyr[:index]).to be_nil
        expect(lyr[:type ]).to be_nil
        expect(lyr[:r    ]).to be_zero
        next
      end

      unless [:standard, :massless].include?(lyr[:type]) # air wall mat
        expect(mod1.status).to be_zero
        expect(lyr[:index]).to be_nil
        expect(lyr[:type ]).to be_nil
        expect(lyr[:r    ]).to be_zero
        next
      end

      expect(lyr[:index] < lc.numLayers).to be true

      case lc.nameString
      when "EXTERIOR-ROOF"
        expect(lyr[:index]).to eq(2)
        expect(lyr[:r    ]).to be_within(TOL).of(5.08)
      when "EXTERIOR-WALL"
        expect(lyr[:index]).to eq(2)
        expect(lyr[:r    ]).to be_within(TOL).of(1.47)
      when "Default interior ceiling"
        expect(lyr[:index]).to be_zero
        expect(lyr[:r    ]).to be_within(TOL).of(0.12)
      when "INTERIOR-WALL"
        expect(lyr[:index]).to eq(1)
        expect(lyr[:r    ]).to be_within(TOL).of(0.24)
      else
        expect(lyr[:index]).to be_zero
        expect(lyr[:r    ]).to be_within(TOL).of(0.29)
      end
    end

    lyr = mod1.insulatingLayer(nil)
    expect(lyr[:index]).to be_nil
    expect(lyr[:type ]).to be_nil
    expect(lyr[:r    ]).to be_zero
    expect(mod1.debug?).to be true
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m1)

    expect(mod1.clean!).to eq(DBG)
    lyr = mod1.insulatingLayer("")
    expect(lyr[:index]).to be_nil
    expect(lyr[:type ]).to be_nil
    expect(lyr[:r    ]).to be_zero
    expect(mod1.debug?).to be true
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m1)

    expect(mod1.clean!).to eq(DBG)
    lyr = mod1.insulatingLayer(model)
    expect(lyr[:index]).to be_nil
    expect(lyr[:type ]).to be_nil
    expect(lyr[:r    ]).to be_zero
    expect(mod1.debug?).to be true
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m1)

    eWall1 = model.getSurfaceByName(n1)
    expect(eWall1).to_not be_empty
    eWall1 = eWall1.get

    expect(mod1.clean!).to eq(DBG)
    lyr = mod1.insulatingLayer(eWall1)
    expect(lyr[:index]).to be_nil
    expect(lyr[:type ]).to be_nil
    expect(lyr[:r    ]).to be_zero
    expect(mod1.debug?).to be true
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m2)
  end

  it "checks for spandrels" do
    translator = OpenStudio::OSVersion::VersionTranslator.new
    expect(mod1.clean!).to eq(DBG)

    file  = File.join(__dir__, "files/osms/out/seb2.osm")
    path  = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model).to_not be_empty
    model = model.get

    office_walls = []
    # Smalloffice 1 Wall 1
    # Smalloffice 1 Wall 2
    # Smalloffice 1 Wall 6
    plenum_walls = []
    # Level0 Small office 1 Ceiling Plenum AbvClgPlnmWall 6
    # Level0 Small office 1 Ceiling Plenum AbvClgPlnmWall 2
    # Level0 Small office 1 Ceiling Plenum AbvClgPlnmWall 1

    model.getSurfaces.each do |s|
      next unless s.outsideBoundaryCondition.downcase == "outdoors"
      next unless s.surfaceType.downcase == "wall"

      expect(mod1.spandrel?(s)).to be false

      if s.nameString.downcase.include?("smalloffice 1")
        office_walls << s
      elsif s.nameString.downcase.include?("small office 1 ceiling plenum")
        plenum_walls << s
      end
    end

    expect(office_walls.size).to eq(3)
    expect(plenum_walls.size).to eq(3)
    expect(mod1.status).to be_zero

    # Tag Small Office walls (& plenum walls) in SEB as 'spandrels'.
    tag = "spandrel"

    (office_walls + plenum_walls).each do |wall|
      expect(wall.additionalProperties.setFeature(tag, true)).to be true
      expect(wall.additionalProperties.hasFeature(tag)).to be true
      prop = wall.additionalProperties.getFeatureAsBoolean(tag)
      expect(prop).to_not be_empty
      expect(prop.get).to be true
      expect(mod1.spandrel?(wall)).to be true
    end

    expect(mod1.status).to be_zero
  end

  it "checks scheduleRulesetMinMax (from within class instances)" do
    translator = OpenStudio::OSVersion::VersionTranslator.new
    expect(cls1.level).to eq(DBG)
    expect(cls1.clean!).to eq(DBG)

    file  = File.join(__dir__, "files/osms/out/seb2.osm")
    path  = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model).to_not be_empty
    model = model.get

    cl1 = OpenStudio::Model::ScheduleRuleset
    cl2 = OpenStudio::Model::ScheduleConstant
    sc1 = "Space Thermostat Cooling Setpoint"
    sc2 = "Schedule Constant 1"
    m1  = "Invalid 'sched' arg #1 (OSut::scheduleRulesetMinMax)"
    m2  = "'#{sc2}' #{cl2}? expecting #{cl1} (OSut::scheduleRulesetMinMax)"

    sched = model.getScheduleRulesetByName(sc1)
    expect(sched).to_not be_empty
    sched = sched.get
    expect(sched).to be_a(cl1)

    sch = model.getScheduleConstantByName(sc2)
    expect(sch).to_not be_empty
    sch = sch.get
    expect(sch).to be_a(cl2)

    # Valid case.
    minmax = cls1.scheduleRulesetMinMax(sched)
    expect(minmax).to be_a(Hash)
    expect(minmax).to have_key(:min)
    expect(minmax).to have_key(:max)
    expect(minmax[:min]).to be_within(TOL).of(23.89)
    expect(minmax[:max]).to be_within(TOL).of(23.89)
    expect(cls1.status).to be_zero
    expect(cls1.logs).to be_empty

    # Invalid parameter.
    minmax = cls1.scheduleRulesetMinMax(nil)
    expect(minmax).to be_a(Hash)
    expect(minmax).to have_key(:min)
    expect(minmax).to have_key(:max)
    expect(minmax[:min]).to be_nil
    expect(minmax[:max]).to be_nil
    expect(cls1.debug?).to be true
    expect(cls1.logs.size).to eq(1)
    expect(cls1.logs.first[:message]).to eq(m1)

    # Invalid parameter.
    expect(cls1.clean!).to eq(DBG)
    minmax = cls1.scheduleRulesetMinMax(model)
    expect(minmax).to be_a(Hash)
    expect(minmax).to have_key(:min)
    expect(minmax).to have_key(:max)
    expect(minmax[:min]).to be_nil
    expect(minmax[:max]).to be_nil
    expect(cls1.debug?).to be true
    expect(cls1.logs.size).to eq(1)
    expect(cls1.logs.first[:message]).to eq(m1)

    # Invalid parameter (wrong schedule type).
    expect(cls1.clean!).to eq(DBG)
    minmax = cls1.scheduleRulesetMinMax(sch)
    expect(minmax).to be_a(Hash)
    expect(minmax).to have_key(:min)
    expect(minmax).to have_key(:max)
    expect(minmax[:min]).to be_nil
    expect(minmax[:max]).to be_nil
    expect(cls1.debug?).to be true
    expect(cls1.logs.size).to eq(1)
    expect(cls1.logs.first[:message]).to eq(m2)
  end

  it "checks scheduleConstantMinMax" do
    translator = OpenStudio::OSVersion::VersionTranslator.new
    expect(cls1.clean!).to eq(DBG)

    file  = File.join(__dir__, "files/osms/out/seb2.osm")
    path  = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model).to_not be_empty
    model = model.get

    sc1 = "Schedule Constant 1"
    sc2 = "Space Thermostat Cooling Setpoint"
    cl1 = OpenStudio::Model::ScheduleConstant
    cl2 = OpenStudio::Model::ScheduleRuleset
    m1  = "Invalid 'sched' arg #1 (OSut::scheduleConstantMinMax)"
    m2  = "'#{sc2}' #{cl2}? expecting #{cl1} (OSut::scheduleConstantMinMax)"

    sched = model.getScheduleConstantByName(sc1)
    expect(sched).to_not be_empty
    sched = sched.get
    expect(sched).to be_a(cl1)

    sch = model.getScheduleRulesetByName(sc2)
    expect(sch).to_not be_empty
    sch = sch.get
    expect(sch).to be_a(cl2)

    # Valid case.
    minmax = cls1.scheduleConstantMinMax(sched)
    expect(minmax).to be_a(Hash)
    expect(minmax).to have_key(:min)
    expect(minmax).to have_key(:max)
    expect(minmax[:min]).to be_within(TOL).of(139.88)
    expect(minmax[:min]).to be_within(TOL).of(139.88)
    expect(cls1.status).to be_zero
    expect(cls1.logs).to be_empty

    # Invalid parameter.
    minmax = cls1.scheduleConstantMinMax(nil)
    expect(minmax).to be_a(Hash)
    expect(minmax).to have_key(:min)
    expect(minmax).to have_key(:max)
    expect(minmax[:min]).to be_nil
    expect(minmax[:max]).to be_nil
    expect(cls1.debug?).to be true
    expect(cls1.logs.size).to eq(1)
    expect(cls1.logs.first[:message]).to eq(m1)

    # Invalid parameter.
    expect(cls1.clean!).to eq(DBG)
    minmax = cls1.scheduleConstantMinMax(model)
    expect(minmax).to be_a(Hash)
    expect(minmax).to have_key(:min)
    expect(minmax).to have_key(:max)
    expect(minmax[:min]).to be_nil
    expect(minmax[:max]).to be_nil
    expect(cls1.debug?).to be true
    expect(cls1.logs.size).to eq(1)
    expect(cls1.logs.first[:message]).to eq(m1)

    # Invalid parameter (wrong schedule type)
    expect(cls1.clean!).to eq(DBG)
    minmax = cls1.scheduleConstantMinMax(sch)
    expect(minmax).to be_a(Hash)
    expect(minmax).to have_key(:min)
    expect(minmax).to have_key(:max)
    expect(minmax[:min]).to be_nil
    expect(minmax[:max]).to be_nil
    expect(cls1.debug?).to be true
    expect(cls1.logs.size).to eq(1)
    expect(cls1.logs.first[:message]).to eq(m2)
  end

  it "checks scheduleCompactMinMax (from within module instances)" do
    translator = OpenStudio::OSVersion::VersionTranslator.new
    expect(mod1.clean!).to eq(DBG)

    file  = File.join(__dir__, "files/osms/out/seb2.osm")
    path  = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model).to_not be_empty
    model = model.get

    spt = 22
    sc2 = "Building HVAC Operation"
    cl1 = OpenStudio::Model::ScheduleCompact
    cl2 = OpenStudio::Model::Schedule

    m1 = "Invalid 'sched' arg #1 (OSut::scheduleCompactMinMax)"
    m2 = "'#{sc2}' #{cl2}? expecting #{cl1} (OSut::scheduleCompactMinMax)"

    sched = OpenStudio::Model::ScheduleCompact.new(model, spt)
    expect(sched).to be_a(OpenStudio::Model::ScheduleCompact)
    sched.setName("compact schedule")

    sch = model.getScheduleByName(sc2)
    expect(sch).to_not be_empty
    sch = sch.get

    # Valid case.
    minmax = mod1.scheduleCompactMinMax(sched)
    expect(minmax).to be_a(Hash)
    expect(minmax).to have_key(:min)
    expect(minmax).to have_key(:max)
    expect(minmax[:min]).to be_within(TOL).of(spt)
    expect(minmax[:min]).to be_within(TOL).of(spt)
    expect(mod1.status).to be_zero
    expect(mod1.logs).to be_empty

    # Invalid parameter.
    minmax = mod1.scheduleCompactMinMax(nil)
    expect(minmax).to be_a(Hash)
    expect(minmax).to have_key(:min)
    expect(minmax).to have_key(:max)
    expect(minmax[:min]).to be_nil
    expect(minmax[:max]).to be_nil
    expect(mod1.debug?).to be true
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m1)

    expect(mod1.clean!).to eq(DBG)

    # Invalid parameter.
    minmax = mod1.scheduleCompactMinMax(model)
    expect(minmax).to be_a(Hash)
    expect(minmax).to have_key(:min)
    expect(minmax).to have_key(:max)
    expect(minmax[:min]).to be_nil
    expect(minmax[:max]).to be_nil
    expect(mod1.debug?).to be true
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m1)

    expect(mod1.clean!).to eq(DBG)

    # Invalid parameter (wrong schedule type)
    minmax = mod1.scheduleCompactMinMax(sch)
    expect(minmax).to be_a(Hash)
    expect(minmax).to have_key(:min)
    expect(minmax).to have_key(:max)
    expect(minmax[:min]).to be_nil
    expect(minmax[:max]).to be_nil
    expect(mod1.debug?).to be true
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m2)
  end

  it "checks min/max heat/cool scheduled setpoints (as a module method)" do
    module M
      extend OSut
    end

    translator = OpenStudio::OSVersion::VersionTranslator.new
    expect(M.clean!).to eq(DBG)

    file  = File.join(__dir__, "files/osms/out/seb2.osm")
    path  = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model).to_not be_empty
    model = model.get

    m1 = "OSut::maxHeatScheduledSetpoint"
    m2 = "OSut::minCoolScheduledSetpoint"
    z1 = "Level 0 Ceiling Plenum Zone"
    z2 = "Single zone"

    model.getThermalZones.each do |z|
      res = M.maxHeatScheduledSetpoint(z)
      expect(res).to be_a(Hash)
      expect(res).to have_key(:spt)
      expect(res).to have_key(:dual)
      expect(res[:spt]).to be_nil                   if z.nameString == z1
      expect(res[:spt]).to be_within(TOL).of(22.11) if z.nameString == z2
      expect(res[:dual]).to eq(false)               if z.nameString == z1
      expect(res[:dual]).to eq(true)                if z.nameString == z2
      expect(M.status).to be_zero

      res = M.minCoolScheduledSetpoint(z)
      expect(res).to be_a(Hash)
      expect(res).to have_key(:spt)
      expect(res).to have_key(:dual)
      expect(res[:spt]).to be_nil                   if z.nameString == z1
      expect(res[:spt]).to be_within(TOL).of(22.78) if z.nameString == z2
      expect(res[:dual]).to eq(false)               if z.nameString == z1
      expect(res[:dual]).to eq(true)                if z.nameString == z2
      expect(M.status).to be_zero
    end

    res = M.maxHeatScheduledSetpoint(nil) # bad argument
    expect(res).to be_a(Hash)
    expect(res).to have_key(:spt)
    expect(res).to have_key(:dual)
    expect(res[:spt]).to be_nil
    expect(res[:dual]).to eq(false)
    expect(M.debug?).to be true
    expect(M.logs.size).to eq(1)
    expect(M.logs.first[:message]).to eq("Invalid 'zone' arg #1 (#{m1})")
    expect(M.clean!).to eq(DBG)

    res = M.minCoolScheduledSetpoint(nil) # bad argument
    expect(res).to be_a(Hash)
    expect(res).to have_key(:spt)
    expect(res).to have_key(:dual)
    expect(res[:spt]).to be_nil
    expect(res[:dual]).to eq(false)
    expect(M.debug?).to be true
    expect(M.logs.size).to eq(1)
    expect(M.logs.first[:message]).to eq("Invalid 'zone' arg #1 (#{m2})")
    expect(M.clean!).to eq(DBG)

    res = M.maxHeatScheduledSetpoint(model) # bad argument
    expect(res).to be_a(Hash)
    expect(res).to have_key(:spt)
    expect(res).to have_key(:dual)
    expect(res[:spt]).to be_nil
    expect(res[:dual]).to eq(false)
    expect(M.debug?).to be true
    expect(M.logs.size).to eq(1)
    expect(M.logs.first[:message]).to eq("Invalid 'zone' arg #1 (#{m1})")
    expect(M.clean!).to eq(DBG)

    res = M.minCoolScheduledSetpoint(model) # bad argument
    expect(res).to be_a(Hash)
    expect(res).to have_key(:spt)
    expect(res).to have_key(:dual)
    expect(res[:spt]).to be_nil
    expect(res[:dual]).to eq(false)
    expect(M.debug?).to be true
    expect(M.logs.size).to eq(1)
    expect(M.logs.first[:message]).to eq("Invalid 'zone' arg #1 (#{m2})")
    expect(M.clean!).to eq(DBG)

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # Add electric heating to 1x slab.
    entry = model.getSpaceByName("Entry way 1")
    expect(entry).to_not be_empty
    entry = entry.get
    floor = entry.surfaces.select{ |s| s.surfaceType == "Floor" }
    expect(floor).to be_a(Array)
    expect(floor.size).to eq(1)
    floor = floor.first

    expect(entry.thermalZone).to_not be_empty
    tzone = entry.thermalZone.get

    # Retrieve construction.
    expect(floor.isConstructionDefaulted).to be false
    c = floor.construction
    expect(c).to_not be_empty
    c = c.get.to_LayeredConstruction
    expect(c).to_not be_empty
    c = c.get

    # Recover single construction layer (concrete slab).
    layers = OpenStudio::Model::MaterialVector.new
    layers << c.layers.first
    layers << c.layers.first
    expect(c.layers.size).to eq(1)

    # Generate construction with internal heat source.
    cc = OpenStudio::Model::ConstructionWithInternalSource.new(model)
    cc.setName("ihs")
    expect(cc.setLayers(layers)).to be true
    expect(cc.setSourcePresentAfterLayerNumber(1)).to be true
    expect(cc.setTemperatureCalculationRequestedAfterLayerNumber(1)).to be true
    expect(floor.setConstruction(cc)).to be true

    # Test 'fixed interval' schedule. Annual time series - no variation.
    start  = model.getYearDescription.makeDate(1, 1)
    inter  = OpenStudio::Time.new(0, 1, 0, 0)
    values = OpenStudio.createVector(Array.new(8760, 22.78))
    series = OpenStudio::TimeSeries.new(start, inter, values, "")
    limits = OpenStudio::Model::ScheduleTypeLimits.new(model)
    limits.setName("Radiant Electric Heating Setpoint Schedule Type Limits")
    expect(limits.setNumericType("Continuous")).to be true
    expect(limits.setUnitType("Temperature")).to be true

    schedule = OpenStudio::Model::ScheduleFixedInterval.new(model)
    schedule.setName("Radiant Electric Heating Setpoint Schedule")
    expect(schedule.setTimeSeries(series)).to be true
    expect(schedule.setTranslatetoScheduleFile(false)).to be true
    expect(schedule.setScheduleTypeLimits(limits)).to be true

    tvals = schedule.timeSeries.values
    expect(tvals).to be_a(OpenStudio::Vector)
    tvals.each { |tval| expect(tval).to be_a(Numeric) }

    availability = M.availabilitySchedule(model)

    # Create radiant electric heating.
    ht = OpenStudio::Model::ZoneHVACLowTemperatureRadiantElectric.new(
            model, availability, schedule)
    ht.setName("radiant electric")
    expect(ht.setRadiantSurfaceType("Floors")).to be true
    expect(ht.addToThermalZone(tzone)).to be true
    expect(tzone.setHeatingPriority(ht, 1)).to be true
    found = false

    tzone.equipment.each do |eq|
      found = true if eq.nameString == "radiant electric"
    end

    expect(found).to be true

    file = File.join(__dir__, "files/osms/out/seb_ihs.osm")
    model.save(file, true)

    # Regardless of the radiant electric heating installation, priority is
    # given to the zone thermostat heating setpoint.
    stpts = M.setpoints(entry)
    expect(stpts[:heating]).to be_within(TOL).of(22.11)

    # Yet if one were to remove the thermostat altogether ...
    tzone.resetThermostatSetpointDualSetpoint
    res = M.maxHeatScheduledSetpoint(tzone)
    expect(res).to be_a(Hash)
    expect(res).to have_key(:spt)
    expect(res).to have_key(:dual)
    expect(res[:spt ]).to_not be_nil
    expect(res[:spt]).to be_within(TOL).of(22.78) # radiant heating
    expect(res[:dual]).to eq(false)

    stpts = M.setpoints(entry)
    expect(stpts[:heating]).to_not be_nil
    expect(stpts[:heating]).to be_within(TOL).of(22.78) # radiant heating
  end

  it "checks for HVAC air loops" do
    translator = OpenStudio::OSVersion::VersionTranslator.new

    cl1 = OpenStudio::Model::Model
    cl2 = NilClass
    m   = "'model' #{cl2}? expecting #{cl1} (OSut::airLoopsHVAC?)"

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    file  = File.join(__dir__, "files/osms/out/seb2.osm")
    path  = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model).to_not be_empty
    model = model.get

    expect(mod1.clean!).to eq(DBG)
    expect(mod1.airLoopsHVAC?(model)).to be true
    expect(mod1.status).to be_zero
    expect(mod1.airLoopsHVAC?(nil)).to be false
    expect(mod1.debug?).to be true
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m)

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    file  = File.join(__dir__, "files/osms/in/5ZoneNoHVAC.osm")
    path  = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model).to_not be_empty
    model = model.get

    expect(mod1.clean!).to eq(DBG)
    expect(mod1.airLoopsHVAC?(model)).to be false
    expect(mod1.status).to be_zero
    expect(mod1.airLoopsHVAC?(nil)).to be false
    expect(mod1.debug?).to be true
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m)
  end

  it "checks for vestibules" do
    translator = OpenStudio::OSVersion::VersionTranslator.new
    expect(mod1.clean!).to eq(DBG)

    # Tag "Entry way 1" in SEB as a vestibule.
    file  = File.join(__dir__, "files/osms/out/seb2.osm")
    path  = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model).to_not be_empty
    model = model.get

    tag   = "vestibule"
    entry = model.getSpaceByName("Entry way 1")
    expect(entry).to_not be_empty
    entry = entry.get
    expect(entry.additionalProperties.hasFeature(tag)).to be false
    expect(mod1.vestibule?(entry)).to be false
    expect(mod1.status).to be_zero

    expect(entry.additionalProperties.setFeature(tag, true)).to be true
    expect(entry.additionalProperties.hasFeature(tag)).to be true
    prop = entry.additionalProperties.getFeatureAsBoolean(tag)
    expect(prop).to_not be_empty
    expect(prop.get).to be true
    expect(mod1.vestibule?(entry)).to be true
    expect(mod1.status).to be_zero
  end

  it "checks for setpoints, plenums, attics" do
    translator = OpenStudio::OSVersion::VersionTranslator.new

    cl1 = OpenStudio::Model::Space
    cl2 = OpenStudio::Model::Model
    mt1 = "(OSut::plenum?)"
    mt2 = "(OSut::heatingTemperatureSetpoints?)"
    mt3 = "(OSut::setpoints)"
    ms1 = "'space' NilClass? expecting #{cl1} #{mt1}"
    ms2 = "'model' NilClass? expecting #{cl2} #{mt2}"
    ms3 = "'space' NilClass? expecting #{cl1} #{mt3}"

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # Invalid input.
    expect(mod1.clean!).to eq(DBG)
    expect(mod1.plenum?(nil)).to be false
    expect(mod1.debug?).to be true
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(ms1)

    expect(mod1.clean!).to eq(DBG)
    expect(mod1.heatingTemperatureSetpoints?(nil)).to be false
    expect(mod1.debug?).to be true
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(ms2)

    expect(mod1.clean!).to eq(DBG)
    expect(mod1.setpoints(nil)[:heating]).to be_nil
    expect(mod1.debug?).to be true
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(ms3)

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    file   = File.join(__dir__, "files/osms/in/warehouse.osm")
    path   = OpenStudio::Path.new(file)
    model  = translator.loadModel(path)
    expect(model).to_not be_empty
    model  = model.get

    # Despite different heating setpoints, all 3 thermal spaces/zones have some
    # heating and some cooling, i.e. not strictly REFRIGERATED nor SEMIHEATED.
    model.getSpaces.each do |space|
      expect(mod1.refrigerated?(space)).to be false
      expect(mod1.semiheated?(space)).to be false
    end

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    file   = File.join(__dir__, "files/osms/out/seb2.osm")
    path   = OpenStudio::Path.new(file)
    model  = translator.loadModel(path)
    expect(model).to_not be_empty
    model  = model.get
    plenum = model.getSpaceByName("Level 0 Ceiling Plenum")
    expect(plenum).to_not be_empty
    plenum = plenum.get
    expect(mod1.clean!).to eq(DBG)

    model.getSpaces.each do |space|
      next if space == plenum

      zone = space.thermalZone
      expect(zone).to_not be_empty
      zone = zone.get
      heat = mod1.maxHeatScheduledSetpoint(zone)
      cool = mod1.minCoolScheduledSetpoint(zone)

      expect(heat[:spt]).to be_within(TOL).of(22.11)
      expect(cool[:spt]).to be_within(TOL).of(22.78)
      expect(heat[:dual]).to be true
      expect(cool[:dual]).to be true

      expect(space.partofTotalFloorArea).to be true
      expect(mod1.plenum?(space)).to be false
      expect(mod1.unconditioned?(space)).to be false
      expect(mod1.setpoints(space)[:heating]).to be_within(TOL).of(22.11)
      expect(mod1.setpoints(space)[:cooling]).to be_within(TOL).of(22.78)
    end

    zone = plenum.thermalZone
    expect(zone).to_not be_empty
    zone = zone.get
    heat = mod1.maxHeatScheduledSetpoint(zone) # simply returns model info
    cool = mod1.minCoolScheduledSetpoint(zone) # simply returns model info

    expect(heat[:spt]).to be_nil
    expect(cool[:spt]).to be_nil
    expect(heat[:dual]).to be false
    expect(cool[:dual]).to be false

    # "Plenum" spaceType triggers an INDIRECTLYCONDITIONED status; returns
    # defaulted setpoint temperatures.
    expect(plenum.partofTotalFloorArea).to be false
    expect(mod1.plenum?(plenum)).to be true
    expect(mod1.unconditioned?(plenum)).to be false
    expect(mod1.setpoints(plenum)[:heating]).to be_within(TOL).of(21.00)
    expect(mod1.setpoints(plenum)[:cooling]).to be_within(TOL).of(24.00)
    expect(mod1.status).to be_zero

    # Tag plenum as an INDIRECTLYCONDITIONED space (linked to "Open area 1");
    # returns "Open area 1" setpoint temperatures.
    key = "indirectlyconditioned"
    val = "Open area 1"
    expect(plenum.additionalProperties.setFeature(key, val)).to be true
    expect(mod1.plenum?(plenum)).to be true
    expect(mod1.unconditioned?(plenum)).to be false
    expect(mod1.setpoints(plenum)[:heating]).to be_within(TOL).of(22.11)
    expect(mod1.setpoints(plenum)[:cooling]).to be_within(TOL).of(22.78)
    expect(mod1.status).to be_zero

    # Tag plenum instead as an UNCONDITIONED space.
    expect(plenum.additionalProperties.resetFeature(key)).to be true
    key = "space_conditioning_category"
    val = "Unconditioned"
    expect(plenum.additionalProperties.setFeature(key, val)).to be true
    expect(mod1.plenum?(plenum)).to be true
    expect(mod1.unconditioned?(plenum)).to be true
    expect(mod1.setpoints(plenum)[:heating]).to be_nil
    expect(mod1.setpoints(plenum)[:cooling]).to be_nil
    expect(mod1.status).to be_zero

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    file  = File.join(__dir__, "files/osms/in/smalloffice.osm")
    path  = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model).to_not be_empty
    model = model.get
    attic = model.getSpaceByName("Attic")
    expect(attic).to_not be_empty
    attic = attic.get

    model.getSpaces.each do |space|
      next if space == attic

      zone = space.thermalZone
      expect(zone).to_not be_empty
      zone = zone.get
      heat = mod1.maxHeatScheduledSetpoint(zone)
      cool = mod1.minCoolScheduledSetpoint(zone)

      expect(heat[:spt]).to be_within(TOL).of(21.11)
      expect(cool[:spt]).to be_within(TOL).of(23.89)
      expect(heat[:dual]).to be true
      expect(cool[:dual]).to be true

      expect(space.partofTotalFloorArea).to be true
      expect(mod1.plenum?(space)).to be false
      expect(mod1.unconditioned?(space)).to be false
      expect(mod1.setpoints(space)[:heating]).to be_within(TOL).of(21.11)
      expect(mod1.setpoints(space)[:cooling]).to be_within(TOL).of(23.89)
    end

    zone = attic.thermalZone
    expect(zone).to_not be_empty
    zone = zone.get
    heat = mod1.maxHeatScheduledSetpoint(zone)
    cool = mod1.minCoolScheduledSetpoint(zone)

    expect(heat[:spt]).to be_nil
    expect(cool[:spt]).to be_nil
    expect(heat[:dual]).to be false
    expect(cool[:dual]).to be false

    expect(mod1.plenum?(attic)).to be false
    expect(mod1.unconditioned?(attic)).to be true
    expect(attic.partofTotalFloorArea).to be false
    expect(mod1.status).to be_zero

    # Tag attic as an INDIRECTLYCONDITIONED space (linked to "Core_ZN").
    key = "indirectlyconditioned"
    val = "Core_ZN"
    expect(attic.additionalProperties.setFeature(key, val)).to be true
    expect(mod1.plenum?(attic)).to be false
    expect(mod1.unconditioned?(attic)).to be false
    expect(mod1.setpoints(attic)[:heating]).to be_within(TOL).of(21.11)
    expect(mod1.setpoints(attic)[:cooling]).to be_within(TOL).of(23.89)
    expect(mod1.status).to be_zero
    expect(attic.additionalProperties.resetFeature(key)).to be true

    # Tag attic instead as an SEMIHEATED space. First, test an invalid entry.
    key = "space_conditioning_category"
    val = "Demiheated"
    msg = "Invalid '#{key}:#{val}' (OSut::setpoints)"
    expect(attic.additionalProperties.setFeature(key, val)).to be true
    expect(mod1.plenum?(attic)).to be false
    expect(mod1.unconditioned?(attic)).to be true
    expect(mod1.setpoints(attic)[:heating]).to be_nil
    expect(mod1.setpoints(attic)[:cooling]).to be_nil
    expect(attic.additionalProperties.hasFeature(key)).to be true
    cnd = attic.additionalProperties.getFeatureAsString(key)
    expect(cnd).to_not be_empty
    expect(cnd.get).to eq(val)
    expect(mod1.error?).to be true

    # 4x same error, as both plenum? and unconditioned? call setpoints(attic).
    expect(mod1.logs.size).to eq(4)
    mod1.logs.each { |l| expect(l[:message]).to eq(msg) }

    # Now test a valid entry.
    expect(attic.additionalProperties.resetFeature(key)).to be true
    expect(mod1.clean!).to eq(DBG)
    val = "Semiheated"
    expect(attic.additionalProperties.setFeature(key, val)).to be true
    expect(mod1.plenum?(attic)).to be false
    expect(mod1.unconditioned?(attic)).to be false
    expect(mod1.semiheated?(attic)).to be true
    expect(mod1.refrigerated?(attic)).to be false
    expect(mod1.setpoints(attic)[:heating]).to be_within(TOL).of(14.00)
    expect(mod1.setpoints(attic)[:cooling]).to be_nil
    expect(mod1.status).to be_zero
    expect(attic.additionalProperties.hasFeature(key)).to be true
    cnd = attic.additionalProperties.getFeatureAsString(key)
    expect(cnd).to_not be_empty
    expect(cnd.get).to eq(val)

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # Consider adding LargeOffice model to test SDK's "isPlenum" ... @todo
  end

  it "checks availability schedule generation" do
    translator = OpenStudio::OSVersion::VersionTranslator.new
    expect(mod1.clean!).to eq(DBG)

    mdl   = OpenStudio::Model::Model.new
    v     = OpenStudio.openStudioVersion.split(".").join.to_i
    file  = File.join(__dir__, "files/osms/out/seb2.osm")
    path  = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model).to_not be_empty
    model = model.get

    year = model.yearDescription
    expect(year).to_not be_empty
    year = year.get

    am01 = OpenStudio::Time.new(0, 1)
    pm11 = OpenStudio::Time.new(0,23)

    jan01 = year.makeDate(OpenStudio::MonthOfYear.new("Jan"),  1)
    apr30 = year.makeDate(OpenStudio::MonthOfYear.new("Apr"), 30)
    may01 = year.makeDate(OpenStudio::MonthOfYear.new("May"),  1)
    oct31 = year.makeDate(OpenStudio::MonthOfYear.new("Oct"), 31)
    nov01 = year.makeDate(OpenStudio::MonthOfYear.new("Nov"),  1)
    dec31 = year.makeDate(OpenStudio::MonthOfYear.new("Dec"), 31)
    expect(oct31).to be_a(OpenStudio::Date)

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    sch = mod1.availabilitySchedule(model) # ON (default)
    expect(sch).to be_a(OpenStudio::Model::ScheduleRuleset)
    expect(sch.nameString).to eq("ON Availability SchedRuleset")

    limits = sch.scheduleTypeLimits
    expect(limits).to_not be_empty
    limits = limits.get
    expect(limits.nameString).to eq("HVAC Operation ScheduleTypeLimits")

    default = sch.defaultDaySchedule
    expect(default.nameString).to eq("ON Availability dftDaySched")
    expect(default.times).to_not be_empty
    expect(default.values).to_not be_empty
    expect(default.times.size).to eq(1)
    expect(default.values.size).to eq(1)
    expect(default.getValue(am01).to_i).to eq(1)
    expect(default.getValue(pm11).to_i).to eq(1)

    expect(sch.isWinterDesignDayScheduleDefaulted).to be true
    expect(sch.isSummerDesignDayScheduleDefaulted).to be true
    expect(sch.isHolidayScheduleDefaulted).to be true
    expect(sch.isCustomDay1ScheduleDefaulted).to be true unless v < 330
    expect(sch.isCustomDay2ScheduleDefaulted).to be true unless v < 330
    expect(sch.summerDesignDaySchedule).to eq(default)
    expect(sch.winterDesignDaySchedule).to eq(default)
    expect(sch.holidaySchedule).to eq(default)
    expect(sch.customDay1Schedule).to eq(default) unless v < 330
    expect(sch.customDay2Schedule).to eq(default) unless v < 330
    expect(sch.scheduleRules).to be_empty

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    sch = mod1.availabilitySchedule(model, "Off")
    expect(sch).to be_a(OpenStudio::Model::ScheduleRuleset)
    expect(sch.nameString).to eq("OFF Availability SchedRuleset")

    limits = sch.scheduleTypeLimits
    expect(limits).to_not be_empty
    limits = limits.get
    expect(limits.nameString).to eq("HVAC Operation ScheduleTypeLimits")

    default = sch.defaultDaySchedule
    expect(default.nameString).to eq("OFF Availability dftDaySched")
    expect(default.times).to_not be_empty
    expect(default.values).to_not be_empty
    expect(default.times.size).to eq(1)
    expect(default.values.size).to eq(1)
    expect(default.getValue(am01).to_i).to be_zero
    expect(default.getValue(pm11).to_i).to be_zero

    expect(sch.isWinterDesignDayScheduleDefaulted).to be true
    expect(sch.isSummerDesignDayScheduleDefaulted).to be true
    expect(sch.isHolidayScheduleDefaulted).to be true
    expect(sch.isCustomDay1ScheduleDefaulted).to be true unless v < 330
    expect(sch.isCustomDay2ScheduleDefaulted).to be true unless v < 330
    expect(sch.summerDesignDaySchedule).to eq(default)
    expect(sch.winterDesignDaySchedule).to eq(default)
    expect(sch.holidaySchedule).to eq(default)
    expect(sch.customDay1Schedule).to eq(default) unless v < 330
    expect(sch.customDay2Schedule).to eq(default) unless v < 330
    expect(sch.scheduleRules).to be_empty

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    sch = mod1.availabilitySchedule(model, "Winter")
    expect(sch).to be_a(OpenStudio::Model::ScheduleRuleset)
    expect(sch.nameString).to eq("WINTER Availability SchedRuleset")

    limits = sch.scheduleTypeLimits
    expect(limits).to_not be_empty
    limits = limits.get
    expect(limits.nameString).to eq("HVAC Operation ScheduleTypeLimits")

    default = sch.defaultDaySchedule
    expect(default.nameString).to eq("WINTER Availability dftDaySched")
    expect(default.times).to_not be_empty
    expect(default.values).to_not be_empty
    expect(default.times.size).to eq(1)
    expect(default.values.size).to eq(1)
    expect(default.getValue(am01).to_i).to eq(1)
    expect(default.getValue(pm11).to_i).to eq(1)

    expect(sch.isWinterDesignDayScheduleDefaulted).to be true
    expect(sch.isSummerDesignDayScheduleDefaulted).to be true
    expect(sch.isHolidayScheduleDefaulted).to be true
    expect(sch.isCustomDay1ScheduleDefaulted).to be true unless v < 330
    expect(sch.isCustomDay2ScheduleDefaulted).to be true unless v < 330
    expect(sch.summerDesignDaySchedule).to eq(default)
    expect(sch.winterDesignDaySchedule).to eq(default)
    expect(sch.holidaySchedule).to eq(default)
    expect(sch.customDay1Schedule).to eq(default) unless v < 330
    expect(sch.customDay2Schedule).to eq(default) unless v < 330
    expect(sch.scheduleRules.size).to eq(1)

    sch.getDaySchedules(jan01, apr30).each do |day_schedule|
      expect(day_schedule.times).to_not be_empty
      expect(day_schedule.values).to_not be_empty
      expect(day_schedule.times.size).to eq(1)
      expect(day_schedule.values.size).to eq(1)
      expect(day_schedule.getValue(am01).to_i).to eq(1)
      expect(day_schedule.getValue(pm11).to_i).to eq(1)
    end

    sch.getDaySchedules(may01, oct31).each do |day_schedule|
      expect(day_schedule.times).to_not be_empty
      expect(day_schedule.values).to_not be_empty
      expect(day_schedule.times.size).to eq(1)
      expect(day_schedule.values.size).to eq(1)
      expect(day_schedule.getValue(am01).to_i).to be_zero
      expect(day_schedule.getValue(pm11).to_i).to be_zero
    end

    sch.getDaySchedules(nov01, dec31).each do |day_schedule|
      expect(day_schedule.times).to_not be_empty
      expect(day_schedule.values).to_not be_empty
      expect(day_schedule.times.size).to eq(1)
      expect(day_schedule.values.size).to eq(1)
      expect(day_schedule.getValue(am01).to_i).to eq(1)
      expect(day_schedule.getValue(pm11).to_i).to eq(1)
    end

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    another = mod1.availabilitySchedule(model, "Winter")
    expect(another.nameString).to eq(sch.nameString)

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    sch = mod1.availabilitySchedule(model, "Summer")
    expect(sch).to be_a(OpenStudio::Model::ScheduleRuleset)
    expect(sch.nameString).to eq("SUMMER Availability SchedRuleset")

    limits = sch.scheduleTypeLimits
    expect(limits).to_not be_empty
    limits = limits.get
    expect(limits.nameString).to eq("HVAC Operation ScheduleTypeLimits")

    default = sch.defaultDaySchedule
    expect(default.nameString).to eq("SUMMER Availability dftDaySched")
    expect(default.times).to_not be_empty
    expect(default.values).to_not be_empty
    expect(default.times.size).to eq(1)
    expect(default.values.size).to eq(1)
    expect(default.getValue(am01).to_i).to be_zero
    expect(default.getValue(pm11).to_i).to be_zero

    expect(sch.isWinterDesignDayScheduleDefaulted).to be true
    expect(sch.isSummerDesignDayScheduleDefaulted).to be true
    expect(sch.isHolidayScheduleDefaulted).to be true
    expect(sch.isCustomDay1ScheduleDefaulted).to be true unless v < 330
    expect(sch.isCustomDay2ScheduleDefaulted).to be true unless v < 330
    expect(sch.summerDesignDaySchedule).to eq(default)
    expect(sch.winterDesignDaySchedule).to eq(default)
    expect(sch.holidaySchedule).to eq(default)
    expect(sch.customDay1Schedule).to eq(default) unless v < 330
    expect(sch.customDay2Schedule).to eq(default) unless v < 330
    expect(sch.scheduleRules.size).to eq(1)

    sch.getDaySchedules(jan01, apr30).each do |day_schedule|
      expect(day_schedule.times).to_not be_empty
      expect(day_schedule.values).to_not be_empty
      expect(day_schedule.times.size).to eq(1)
      expect(day_schedule.values.size).to eq(1)
      expect(day_schedule.getValue(am01).to_i).to be_zero
      expect(day_schedule.getValue(pm11).to_i).to be_zero
    end

    sch.getDaySchedules(may01, oct31).each do |day_schedule|
      expect(day_schedule.times).to_not be_empty
      expect(day_schedule.values).to_not be_empty
      expect(day_schedule.times.size).to eq(1)
      expect(day_schedule.values.size).to eq(1)
      expect(day_schedule.getValue(am01).to_i).to eq(1)
      expect(day_schedule.getValue(pm11).to_i).to eq(1)
    end

    sch.getDaySchedules(nov01, dec31).each do |day_schedule|
      expect(day_schedule.times).to_not be_empty
      expect(day_schedule.values).to_not be_empty
      expect(day_schedule.times.size).to eq(1)
      expect(day_schedule.values.size).to eq(1)
      expect(day_schedule.getValue(am01).to_i).to be_zero
      expect(day_schedule.getValue(pm11).to_i).to be_zero
    end
  end

  it "checks model transformation" do
    translator = OpenStudio::OSVersion::VersionTranslator.new
    expect(mod1.reset(DBG)).to eq(DBG)
    expect(mod1.level).to eq(DBG)
    expect(mod1.clean!).to eq(DBG)

    # Successful test.
    file  = File.join(__dir__, "files/osms/out/seb2.osm")
    path  = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model).to_not be_empty
    model = model.get

    model.getSpaces.each do |space|
      tr = mod1.transforms(space)
      expect(tr).to be_a(Hash)
      expect(tr).to have_key(:t)
      expect(tr).to have_key(:r)
      expect(tr[:t]).to be_a(OpenStudio::Transformation)
      expect(tr[:r]).to within(TOL).of(0)
    end

    # Invalid input test.
    expect(mod1.status).to be_zero
    m1 = "Invalid 'group' arg #2 (OSut::transforms)"
    tr = mod1.transforms(nil)
    expect(tr).to be_a(Hash)
    expect(tr).to have_key(:t)
    expect(tr).to have_key(:r)
    expect(tr[:t]).to be_nil
    expect(tr[:r]).to be_nil
    expect(mod1.debug?).to be true
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m1)
    expect(mod1.clean!).to eq(DBG)


    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # Realignment of flat surfaces.
    vtx  = OpenStudio::Point3dVector.new
    vtx << OpenStudio::Point3d.new(  1,  4,  0)
    vtx << OpenStudio::Point3d.new(  2,  2,  0)
    vtx << OpenStudio::Point3d.new(  6,  4,  0)
    vtx << OpenStudio::Point3d.new(  5,  6,  0)

    origin  = vtx[1]
    hyp     = (origin - vtx[0]).length
    hyp2    = (origin - vtx[2]).length
    right   = OpenStudio::Point3d.new(origin.x + 10, origin.y, origin.z     )
    zenith  = OpenStudio::Point3d.new(origin.x,      origin.y, origin.z + 10)
    seg     = vtx[2] - origin
    axis    = zenith - origin
    droite  = right  - origin
    radians = OpenStudio::getAngle(droite, seg)
    degrees = OpenStudio::radToDeg(radians)
    expect(degrees).to be_within(TOL).of(26.565)

    r = OpenStudio::Transformation.rotation(origin, axis, radians)
    a = r.inverse * vtx

    expect(mod1.same?(a[1], vtx[1])).to be true
    expect(a[0].x - a[1].x).to be_within(TOL).of(0)
    expect(a[2].x - a[1].x).to be_within(TOL).of(hyp2)
    expect(a[3].x - a[2].x).to be_within(TOL).of(0)
    expect(a[0].y - a[1].y).to be_within(TOL).of(hyp)
    expect(a[2].y - a[1].y).to be_within(TOL).of(0)
    expect(a[3].y - a[1].y).to be_within(TOL).of(hyp)

    pts = r * a
    expect(mod1.same?(pts, vtx)).to be true

    output1 = mod1.realignedFace(vtx)
    expect(mod1.status).to be_zero
    expect(output1).to be_a Hash
    expect(output1).to have_key(:set)
    expect(output1).to have_key(:box)
    expect(output1).to have_key(:bbox)
    expect(output1).to have_key(:t)
    expect(output1).to have_key(:r)
    expect(output1).to have_key(:o)

    ubox1  = output1[ :box]
    ubbox1 = output1[:bbox]

    # Realign a previously realigned surface?
    output2 = mod1.realignedFace(output1[:box])
    ubox2   = output1[ :box]
    ubbox2  = output1[:bbox]

    # Realigning a previously realigned polygon has no effect (== safe).
    expect(mod1.same?(ubox1, ubox2, false)).to be true
    expect(mod1.same?(ubbox1, ubbox2, false)).to be true

    bounded_area  = OpenStudio.getArea(ubox1)
    bounding_area = OpenStudio.getArea(ubbox1)
    expect(bounded_area).to_not be_empty
    expect(bounding_area).to_not be_empty
    expect(bounded_area.get).to be_within(TOL).of(bounding_area.get)

    bounded_area  = OpenStudio.getArea(ubox2)
    bounding_area = OpenStudio.getArea(ubbox2)
    expect(bounded_area).to_not be_empty
    expect(bounding_area).to_not be_empty
    expect(bounded_area.get).to be_within(TOL).of(bounding_area.get)
    expect(mod1.status).to be_zero

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # Repeat with slight change in orientation.
    vtx  = OpenStudio::Point3dVector.new
    vtx << OpenStudio::Point3d.new(  2,  6,  0)
    vtx << OpenStudio::Point3d.new(  1,  4,  0)
    vtx << OpenStudio::Point3d.new(  5,  2,  0)
    vtx << OpenStudio::Point3d.new(  6,  4,  0)

    output3 = mod1.realignedFace(vtx)
    ubox3   = output3[ :box]
    ubbox3  = output3[:bbox]

    # Realign a previously realigned surface?
    output4 = mod1.realignedFace(output3[:box])
    ubox4   = output4[ :box]
    ubbox4  = output4[:bbox]

    # Realigning a previously realigned polygon has no effect (== safe).
    expect(mod1.same?(ubox1, ubox3, false)).to be true
    expect(mod1.same?(ubbox1, ubbox3, false)).to be true
    expect(mod1.same?(ubox1, ubox4, false)).to be true
    expect(mod1.same?(ubbox1, ubbox4, false)).to be true

    bounded_area  = OpenStudio.getArea(ubox3)
    bounding_area = OpenStudio.getArea(ubbox3)
    expect(bounded_area).to_not be_empty
    expect(bounding_area).to_not be_empty
    expect(bounded_area.get).to be_within(TOL).of(bounding_area.get)

    bounded_area  = OpenStudio.getArea(ubox4)
    bounding_area = OpenStudio.getArea(ubbox4)
    expect(bounded_area).to_not be_empty
    expect(bounding_area).to_not be_empty
    expect(bounded_area.get).to be_within(TOL).of(bounding_area.get)
    expect(mod1.status).to be_zero

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # Repeat with changes in vertex sequence.
    vtx  = OpenStudio::Point3dVector.new
    vtx << OpenStudio::Point3d.new(  6,  4,  0)
    vtx << OpenStudio::Point3d.new(  5,  6,  0)
    vtx << OpenStudio::Point3d.new(  1,  4,  0)
    vtx << OpenStudio::Point3d.new(  2,  2,  0)

    output5 = mod1.realignedFace(vtx)
    ubox5   = output5[ :box]
    ubbox5  = output5[:bbox]

    # Realign a previously realigned surface?
    output6 = mod1.realignedFace(output5[:box])
    ubox6   = output6[ :box]
    ubbox6  = output6[:bbox]

    # Realigning a previously realigned polygon has no effect (== safe).
    expect(mod1.same?(ubox1, ubox5)).to be true
    expect(mod1.same?(ubox1, ubox6)).to be true
    expect(mod1.same?(ubbox1, ubbox5)).to be true
    expect(mod1.same?(ubbox1, ubbox6)).to be true
    expect(mod1.same?(ubox5, ubox6, false)).to be true
    expect(mod1.same?(ubox5, ubbox5, false)).to be true
    expect(mod1.same?(ubbox5, ubox6, false)).to be true
    expect(mod1.same?(ubox6, ubbox6, false)).to be true

    bounded_area  = OpenStudio.getArea(ubox5)
    bounding_area = OpenStudio.getArea(ubbox5)
    expect(bounded_area).to_not be_empty
    expect(bounding_area).to_not be_empty
    expect(bounded_area.get).to be_within(TOL).of(bounding_area.get)

    bounded_area  = OpenStudio.getArea(ubox6)
    bounding_area = OpenStudio.getArea(ubbox6)
    expect(bounded_area).to_not be_empty
    expect(bounding_area).to_not be_empty
    expect(bounded_area.get).to be_within(TOL).of(bounding_area.get)
    expect(mod1.status).to be_zero

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # Repeat with slight change in orientation (vertices resequenced).
    vtx  = OpenStudio::Point3dVector.new
    vtx << OpenStudio::Point3d.new(  5,  2,  0)
    vtx << OpenStudio::Point3d.new(  6,  4,  0)
    vtx << OpenStudio::Point3d.new(  2,  6,  0)
    vtx << OpenStudio::Point3d.new(  1,  4,  0)

    output7 = mod1.realignedFace(vtx)
    ubox7   = output7[ :box]
    ubbox7  = output7[:bbox]

    # Realign a previously realigned surface?
    output8 = mod1.realignedFace(ubox7)
    ubox8   = output8[ :box]
    ubbox8  = output8[:bbox]

    # Realigning a previously realigned polygon has no effect (== safe).
    expect(mod1.same?(ubox1, ubox7)).to be true
    expect(mod1.same?(ubox1, ubox8)).to be true
    expect(mod1.same?(ubbox1, ubbox7)).to be true
    expect(mod1.same?(ubbox1, ubbox8)).to be true
    expect(mod1.same?(ubox5, ubox7, false)).to be true
    expect(mod1.same?(ubbox5, ubbox7, false)).to be true
    expect(mod1.same?(ubox5, ubox5, false)).to be true
    expect(mod1.same?(ubbox5, ubbox8, false)).to be true

    bounded_area  = OpenStudio.getArea(ubox7)
    bounding_area = OpenStudio.getArea(ubbox7)
    expect(bounded_area).to_not be_empty
    expect(bounding_area).to_not be_empty
    expect(bounded_area.get).to be_within(TOL).of(bounding_area.get)

    bounded_area  = OpenStudio.getArea(ubox8)
    bounding_area = OpenStudio.getArea(ubbox8)
    expect(bounded_area).to_not be_empty
    expect(bounding_area).to_not be_empty
    expect(bounded_area.get).to be_within(TOL).of(bounding_area.get)
    expect(mod1.status).to be_zero

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # Aligned box (wide).
    vtx  = OpenStudio::Point3dVector.new
    vtx << OpenStudio::Point3d.new(  2,  4,  0)
    vtx << OpenStudio::Point3d.new(  2,  2,  0)
    vtx << OpenStudio::Point3d.new(  6,  2,  0)
    vtx << OpenStudio::Point3d.new(  6,  4,  0)

    output9 = mod1.realignedFace(vtx)
    ubox9   = output9[ :box]
    ubbox9  = output9[:bbox]

    output10 = mod1.realignedFace(vtx, true) # no impact
    ubox10   = output10[ :box]
    ubbox10  = output10[:bbox]
    expect(mod1.same?(ubox9, ubox10)).to be true
    expect(mod1.same?(ubbox9, ubbox10)).to be true

    # ... vs aligned box (narrow).
    vtx  = OpenStudio::Point3dVector.new
    vtx << OpenStudio::Point3d.new(  2,  6,  0)
    vtx << OpenStudio::Point3d.new(  2,  2,  0)
    vtx << OpenStudio::Point3d.new(  4,  2,  0)
    vtx << OpenStudio::Point3d.new(  4,  6,  0)

    output11 = mod1.realignedFace(vtx)
    ubox11   = output11[ :box]
    ubbox11  = output11[:bbox]

    output12 = mod1.realignedFace(vtx, true) # narrow, now wide
    ubox12   = output12[ :box]
    ubbox12  = output12[:bbox]
    expect(mod1.same?(ubox11, ubox12)).to be false
    expect(mod1.same?(ubbox11, ubbox12)).to be false
    expect(mod1.same?(ubox12, ubox10)).to be true
    expect(mod1.same?(ubbox12, ubbox10)).to be true

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # Irregular surface (parallelogram).
    vtx  = OpenStudio::Point3dVector.new
    vtx << OpenStudio::Point3d.new(  4,  0,  0)
    vtx << OpenStudio::Point3d.new(  6,  4,  0)
    vtx << OpenStudio::Point3d.new(  3,  8,  0)
    vtx << OpenStudio::Point3d.new(  1,  4,  0)

    output13 = mod1.realignedFace(vtx)
    uset13   = output13[ :set]
    ubox13   = output13[ :box]
    ubbox13  = output13[:bbox]

    # Pre-isolate bounded box (preferable with irregular surfaces).
    box      = mod1.boundedBox(vtx)
    output14 = mod1.realignedFace(box)
    uset14   = output14[ :set]
    ubox14   = output14[ :box]
    ubbox14  = output14[:bbox]
    expect(mod1.same?(uset14, ubox14)).to be true
    expect(mod1.same?(uset14, ubbox14)).to be true
    expect(mod1.same?(uset13, uset14)).to be false
    expect(mod1.same?(ubox13, ubox14)).to be false
    expect(mod1.same?(ubbox13, ubbox14)).to be false

    rset14 = output14[:r] * (output14[:t] * uset14)
    expect(mod1.same?(box, rset14)).to be true

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # Bounded box from an irregular, non-convex, "J"-shaped corridor roof. This
    # is a VERY EXPENSIVE method when dealing with HIGHLY CONVOLUTED polygons !
    vtx  = OpenStudio::Point3dVector.new
    vtx << OpenStudio::Point3d.new(  0.0000000,  0.0000, 3.658)
    vtx << OpenStudio::Point3d.new(  0.0000000, 35.3922, 3.658)
    vtx << OpenStudio::Point3d.new(  7.4183600, 35.3922, 3.658)
    vtx << OpenStudio::Point3d.new(  7.8150800, 35.2682, 3.658)
    vtx << OpenStudio::Point3d.new( 13.8611000, 35.2682, 3.658)
    vtx << OpenStudio::Point3d.new( 13.8611000, 38.9498, 3.658)
    vtx << OpenStudio::Point3d.new(  7.8150800, 38.9498, 3.658)
    vtx << OpenStudio::Point3d.new(  7.8150800, 38.6275, 3.658)
    vtx << OpenStudio::Point3d.new( -0.0674713, 38.6275, 3.658)
    vtx << OpenStudio::Point3d.new( -0.0674713, 48.6247, 3.658)
    vtx << OpenStudio::Point3d.new( -2.5471900, 48.6247, 3.658)
    vtx << OpenStudio::Point3d.new( -2.5471900, 38.5779, 3.658)
    vtx << OpenStudio::Point3d.new( -6.7255500, 38.5779, 3.658)
    vtx << OpenStudio::Point3d.new( -2.5471900,  2.7700, 3.658)
    vtx << OpenStudio::Point3d.new(-14.9024000,  2.7700, 3.658)
    vtx << OpenStudio::Point3d.new(-14.9024000,  0.0000, 3.658)

    bbx = mod1.boundedBox(vtx)
    expect(mod1.fits?(bbx, vtx)).to be true
    puts mod1.logs unless mod1.logs.empty?
    expect(mod1.status).to be_zero
  end

  it "checks surface fits? & overlaps?" do
    expect(mod1.reset(DBG)).to eq(DBG)
    expect(mod1.level).to eq(DBG)
    expect(mod1.clean!).to eq(DBG)
    v = OpenStudio.openStudioVersion.split(".").join.to_i

    p1 = OpenStudio::Point3dVector.new
    p2 = OpenStudio::Point3dVector.new

    p1 << OpenStudio::Point3d.new(3.63, 0, 4.03)
    p1 << OpenStudio::Point3d.new(3.63, 0, 2.44)
    p1 << OpenStudio::Point3d.new(7.34, 0, 2.44)
    p1 << OpenStudio::Point3d.new(7.34, 0, 4.03)

    t = OpenStudio::Transformation.alignFace(p1)

    if v < 340
      p2 << OpenStudio::Point3d.new(3.63, 0, 2.49)
      p2 << OpenStudio::Point3d.new(3.63, 0, 1.00)
      p2 << OpenStudio::Point3d.new(7.34, 0, 1.00)
      p2 << OpenStudio::Point3d.new(7.34, 0, 2.49)
    else
      p2 << OpenStudio::Point3d.new(3.63, 0, 2.47)
      p2 << OpenStudio::Point3d.new(3.63, 0, 1.00)
      p2 << OpenStudio::Point3d.new(7.34, 0, 1.00)
      p2 << OpenStudio::Point3d.new(7.34, 0, 2.47)
    end

    area1 = OpenStudio.getArea(p1)
    area2 = OpenStudio.getArea(p2)
    expect(area1).to_not be_empty
    expect(area2).to_not be_empty
    area1 = area1.get
    area2 = area2.get

    p1a = t.inverse * p1
    p2a = t.inverse * p2

    union = OpenStudio.join(p1a.reverse, p2a.reverse, TOL2)
    expect(union).to_not be_empty
    union = union.get
    area  = OpenStudio.getArea(union)
    expect(area).to_not be_empty
    area  = area.get
    delta = area1 + area2 - area

    res  = OpenStudio.intersect(p1a.reverse, p2a.reverse, TOL)
    expect(res).to_not be_empty
    res  = res.get
    res1 = res.polygon1
    expect(res1).to_not be_empty

    res1_m2 = OpenStudio.getArea(res1)
    expect(res1_m2).to_not be_empty
    res1_m2 = res1_m2.get
    expect(res1_m2).to be_within(TOL2).of(delta)
    expect(mod1.overlaps?(p1a, p2a)).to be true
    expect(mod1.status).to be_zero

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # Tests line intersecting line segments.
    sg1 = OpenStudio::Point3dVector.new
    sg1 << OpenStudio::Point3d.new(18, 0, 0)
    sg1 << OpenStudio::Point3d.new( 8, 3, 0)

    sg2 = OpenStudio::Point3dVector.new
    sg2 << OpenStudio::Point3d.new(12, 14, 0)
    sg2 << OpenStudio::Point3d.new(12,  6, 0)

    expect(mod1.lineIntersection(sg1, sg2)).to be_nil

    sg1 = OpenStudio::Point3dVector.new
    sg1 << OpenStudio::Point3d.new(0.60,19.06, 0)
    sg1 << OpenStudio::Point3d.new(0.60, 0.60, 0)
    sg1 << OpenStudio::Point3d.new(0.00, 0.00, 0)
    sg1 << OpenStudio::Point3d.new(0.00,19.66, 0)
    sgs1 = mod1.segments(sg1)

    sg2 = OpenStudio::Point3dVector.new
    sg2 << OpenStudio::Point3d.new(9.83, 9.83, 0)
    sg2 << OpenStudio::Point3d.new(0.00, 0.00, 0)
    sg2 << OpenStudio::Point3d.new(0.00,19.66, 0)
    sgs2 = mod1.segments(sg2)

    expect(mod1.same?(sg1[2], sg2[1])).to be true
    expect(mod1.same?(sg1[3], sg2[2])).to be true
    expect(mod1.fits?(sg1, sg2)).to be true
    expect(mod1.fits?(sg2, sg1)).to be false
    expect(mod1.same?(mod1.overlap(sg1, sg2), sg1)).to be true
    expect(mod1.same?(mod1.overlap(sg2, sg1), sg1)).to be true

    sg1.each_with_index do |pt, i|
      expect(mod1.pointWithinPolygon?(pt, sg2)).to be true
    end

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

    # Side test: point alignment detection, 'w12' == wall/floor edge (vector).
    w1  = vec[1]
    w2  = vec[2]
    w12 = w2 - w1

    # Side test: same?
    vec2 = mod1.to_p3Dv(vec).to_a
    expect(vec).to_not eq(vec2)
    expect(mod1.same?(vec, vec2)).to be true

    vec2.rotate!(2)
    expect(mod1.same?(vec, vec2)).to be true
    expect(mod1.same?(vec, vec2, false)).to be false

    # 1m x 2m corner door (with 2x edges along wall edges), 4mm sill.
    vec = OpenStudio::Point3dVector.new
    vec << OpenStudio::Point3d.new(  0.5,  0,  2.000)
    vec << OpenStudio::Point3d.new(  0.5,  0,  0.004)
    vec << OpenStudio::Point3d.new(  1.5,  0,  0.004)
    vec << OpenStudio::Point3d.new(  1.5,  0,  2.000)
    door1 = OpenStudio::Model::SubSurface.new(vec, model)

    # Side test: point alignment detection:
    # 'd1_w1': vector from door sill to wall corner 1 ( 0,0,0)
    # 'd1_w2': vector from door sill to wall corner 1 (10,0,0)
    d1 = vec[1]
    d2 = vec[2]
    d1_w1 = w1 - d1
    d1_w2 = w2 - d1
    expect(mod1.pointAlongSegments?(d1, [w1, w2])).to be true

    # Order of arguments matter.
    expect(mod1.fits?(door1, wall)).to be true
    expect(mod1.overlaps?(door1, wall)).to be true
    expect(mod1.fits?(wall, door1)).to be false
    expect(mod1.overlaps?(wall, door1)).to be true

    # The method 'fits' offers an optional 3rd argument: whether a smaller
    # polygon (e.g. door1) needs to 'entirely' fit within the larger polygon.
    # Here, door1 shares its sill with the host wall (as its within 10mm of the
    # wall bottom edge).
    expect(mod1.fits?(door1, wall, true)).to be false

    # Another 1m x 2m corner door, yet entirely beyond the wall surface.
    vec = OpenStudio::Point3dVector.new
    vec << OpenStudio::Point3d.new( 16,  0,  2)
    vec << OpenStudio::Point3d.new( 16,  0,  0)
    vec << OpenStudio::Point3d.new( 17,  0,  0)
    vec << OpenStudio::Point3d.new( 17,  0,  2)
    door2 = OpenStudio::Model::SubSurface.new(vec, model)

    # Door2 fits?, overlaps? Order of arguments doesn't matter.
    expect(mod1.fits?(door2, wall)).to be false
    expect(mod1.overlaps?(door2, wall)).to be false
    expect(mod1.fits?(wall, door2)).to be false
    expect(mod1.overlaps?(wall, door2)).to be false

    # Top-right corner 2m x 2m window, overlapping top-right corner of wall.
    vec = OpenStudio::Point3dVector.new
    vec << OpenStudio::Point3d.new(  9,  0, 11)
    vec << OpenStudio::Point3d.new(  9,  0,  9)
    vec << OpenStudio::Point3d.new( 11,  0,  9)
    vec << OpenStudio::Point3d.new( 11,  0, 11)
    window = OpenStudio::Model::SubSurface.new(vec, model)

    # Window fits?, overlaps?
    expect(mod1.fits?(window, wall)).to be false
    olap = mod1.overlap(window, wall)
    expect(olap.size).to eq(4)
    expect(mod1.fits?(olap, wall)).to be true
    expect(mod1.overlaps?(window, wall)).to be true
    expect(mod1.fits?(wall, window)).to be false
    expect(mod1.overlaps?(wall, window)).to be true

    # A glazed surface, entirely encompassing the wall.
    vec = OpenStudio::Point3dVector.new
    vec << OpenStudio::Point3d.new(  0,  0, 10)
    vec << OpenStudio::Point3d.new(  0,  0,  0)
    vec << OpenStudio::Point3d.new( 10,  0,  0)
    vec << OpenStudio::Point3d.new( 10,  0, 10)
    glazing = OpenStudio::Model::SubSurface.new(vec, model)

    # Glazing fits?, overlaps? parallel?
    expect(mod1.parallel?(glazing, wall)).to be true
    expect(mod1.fits?(glazing, wall)).to be true
    expect(mod1.overlaps?(glazing, wall)).to be true
    expect(mod1.parallel?(wall, glazing)).to be true
    expect(mod1.fits?(wall, glazing)).to be true
    expect(mod1.overlaps?(wall, glazing)).to be true

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # Checks overlaps when 2 surfaces don't share the same plane equation.
    translator = OpenStudio::OSVersion::VersionTranslator.new
    expect(mod1.reset(DBG)).to eq(DBG)
    expect(mod1.level).to eq(DBG)
    expect(mod1.clean!).to eq(DBG)

    v     = OpenStudio.openStudioVersion.split(".").join.to_i
    file  = File.join(__dir__, "files/osms/in/smalloffice.osm")
    path  = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model).to_not be_empty
    model = model.get

    ceiling = model.getSurfaceByName("Core_ZN_ceiling")
    floor   = model.getSurfaceByName("Attic_floor_core")
    roof    = model.getSurfaceByName("Attic_roof_east")
    soffit  = model.getSurfaceByName("Attic_soffit_east")
    south   = model.getSurfaceByName("Attic_roof_south")
    expect(ceiling).to_not be_empty
    expect(floor).to_not be_empty
    expect(roof).to_not be_empty
    expect(soffit).to_not be_empty
    expect(south).to_not be_empty
    ceiling = ceiling.get
    floor   = floor.get
    roof    = roof.get
    soffit  = soffit.get
    south   = south.get

    # Side test: triad, medial and bounded boxes.
    pts   = mod1.nonCollinears(ceiling.vertices, 3)
    box01 = mod1.triadBox(pts)
    box11 = mod1.boundedBox(ceiling)
    expect(mod1.same?(box01, box11)).to be true
    expect(mod1.fits?(box01, ceiling)).to be true

    pts   = mod1.nonCollinears(roof.vertices, 3)
    box02 = mod1.medialBox(pts)
    box12 = mod1.boundedBox(roof)
    expect(mod1.same?(box02, box12)).to be true
    expect(mod1.fits?(box02, roof)).to be true

    box03 = mod1.triadBox(pts)
    expect(mod1.same?(box03, box12)).to be false
    expect(mod1.status).to be_zero

    # For parallel surfaces, OSut's 'overlap' output is consistent regardless
    # of the sequence of arguments. Here, floor and ceiling are mirrored - the
    # former counterclockwise, the latter clockwise. The returned overlap
    # conserves the vertex winding of the first surface.
    expect(mod1.parallel?(floor, ceiling)).to be true
    olap1 = mod1.overlap(floor, ceiling)
    olap2 = mod1.overlap(ceiling, floor)
    expect(mod1.same?(floor.vertices, olap1)).to be true
    expect(mod1.same?(ceiling.vertices, olap2)).to be true

    # When surfaces aren't parallel, 'overlap' remains somewhat consistent if
    # both share a common edge. Here, the flat soffit shares an edge with the
    # sloped roof. The projection of the soffit neatly fits onto the roof, yet
    # the generated overlap will obviously be distorted with respect to the
    # original soffit vertices. Nonetheless, the shared vertices/edge(s) would
    # be preserved.
    olap1 = mod1.overlap(soffit, roof, true)
    olap2 = mod1.overlap(roof, soffit, true)
    expect(mod1.parallel?(olap1, soffit)).to be true
    expect(mod1.parallel?(olap1, roof)).to be false
    expect(mod1.parallel?(olap2, roof)).to be true
    expect(mod1.parallel?(olap2, soffit)).to be false
    expect(olap1.size).to eq(4)
    expect(olap2.size).to eq(4)
    area1 = OpenStudio.getArea(olap1)
    area2 = OpenStudio.getArea(olap2)
    expect(area1).to_not be_empty
    expect(area2).to_not be_empty
    area1 = area1.get
    area2 = area2.get
    expect((area1 - area2).abs).to be > TOL
    pl1 = OpenStudio::Plane.new(olap1)
    pl2 = OpenStudio::Plane.new(olap2)
    n1  = pl1.outwardNormal
    n2  = pl2.outwardNormal
    expect(soffit.plane.outwardNormal.dot(n1)).to be_within(TOL).of(1)
    expect(  roof.plane.outwardNormal.dot(n2)).to be_within(TOL).of(1)

    # When surfaces are neither parallel nor share any edges (e.g. sloped roof
    # vs horizontal floor), the generated overlap is more likely to hold extra
    # vertices, depending on which surface it is cast onto.
    olap1 = mod1.overlap(floor, roof, true)
    olap2 = mod1.overlap(roof, floor, true)
    expect(mod1.parallel?(olap1, floor)).to be true
    expect(mod1.parallel?(olap1, roof)).to be false
    expect(mod1.parallel?(olap2, roof)).to be true
    expect(mod1.parallel?(olap2, floor)).to be false
    expect(olap1.size).to eq(3)
    expect(olap2.size).to eq(5)
    area1 = OpenStudio.getArea(olap1)
    area2 = OpenStudio.getArea(olap2)
    expect(area1).to_not be_empty
    expect(area2).to_not be_empty
    area1 = area1.get
    area2 = area2.get
    expect(area2 - area1).to be > TOL
    pl1 = OpenStudio::Plane.new(olap1)
    pl2 = OpenStudio::Plane.new(olap2)
    n1  = pl1.outwardNormal
    n2  = pl2.outwardNormal
    expect(floor.plane.outwardNormal.dot(n1)).to be_within(TOL).of(1)
    expect( roof.plane.outwardNormal.dot(n2)).to be_within(TOL).of(1)

    # Alternative: first 'cast' vertically one polygon onto the other.
    pl1    = OpenStudio::Plane.new(ceiling.vertices)
    pl2    = OpenStudio::Plane.new(roof.vertices)
    up     = OpenStudio::Point3d.new(0, 0, 1) - OpenStudio::Point3d.new(0, 0, 0)
    down   = OpenStudio::Point3d.new(0, 0,-1) - OpenStudio::Point3d.new(0, 0, 0)
    cast00 = mod1.cast(roof, ceiling, down)
    cast01 = mod1.cast(roof, ceiling, up)
    cast02 = mod1.cast(ceiling, roof, up)
    expect(mod1.parallel?(cast00, ceiling)).to be true
    expect(mod1.parallel?(cast01, ceiling)).to be true
    expect(mod1.parallel?(cast02, roof)).to be true
    expect(mod1.parallel?(cast00, roof)).to be false
    expect(mod1.parallel?(cast01, roof)).to be false
    expect(mod1.parallel?(cast02, ceiling)).to be false

    # As the cast ray is vertical, only the Z-axis coordinate changes.
    cast00.each_with_index do |pt, i|
      expect(pl1.pointOnPlane(pt))
      expect(pt.x).to be_within(TOL).of(roof.vertices[i].x)
      expect(pt.y).to be_within(TOL).of(roof.vertices[i].y)
    end

    # The direction of the cast ray doesn't matter (e.g. up or down).
    cast01.each_with_index do |pt, i|
      expect(pl1.pointOnPlane(pt))
      expect(pt.x).to be_within(TOL).of(cast00[i].x)
      expect(pt.y).to be_within(TOL).of(cast00[i].y)
    end

    # The sequence of arguments matters: the 1st polygon is cast onto the 2nd.
    cast02.each_with_index do |pt, i|
      expect(pl2.pointOnPlane(pt))
      expect(pt.x).to be_within(TOL).of(ceiling.vertices[i].x)
      expect(pt.y).to be_within(TOL).of(ceiling.vertices[i].y)
    end

    # Overlap between roof and vertically-cast ceiling onto roof plane.
    olap02 = mod1.overlap(roof, cast02)
    expect(olap02.size).to eq(3) # not 5
    expect(mod1.fits?(olap02, roof)).to be true

    olap02.each { |pt| expect(pl2.pointOnPlane(pt)) }

    vtx1 = OpenStudio::Point3dVector.new
    vtx1 << OpenStudio::Point3d.new(17.69, 0.00, 0)
    vtx1 << OpenStudio::Point3d.new(13.46, 4.46, 0)
    vtx1 << OpenStudio::Point3d.new( 4.23, 4.46, 0)
    vtx1 << OpenStudio::Point3d.new( 0.00, 0.00, 0)

    vtx2 = OpenStudio::Point3dVector.new
    vtx2 << OpenStudio::Point3d.new( 8.85, 0.00, 0)
    vtx2 << OpenStudio::Point3d.new( 8.85, 4.46, 0)
    vtx2 << OpenStudio::Point3d.new( 4.23, 4.46, 0)
    vtx2 << OpenStudio::Point3d.new( 4.23, 0.00, 0)

    expect(mod1.pointAlongSegment?(vtx2[1], [ vtx1[1], vtx1[2] ])).to be true
    expect(mod1.pointAlongSegments?(vtx2[1], vtx1)).to be true
    expect(mod1.pointWithinPolygon?(vtx2[1], vtx1)).to be true
    expect(mod1.fits?(vtx2, vtx1)).to be true

    # Bounded box test.
    cast03 = mod1.cast(ceiling, south, down)
    expect(mod1.rectangular?(cast03)).to be true
    olap03 = mod1.overlap(south, cast03)
    expect(mod1.parallel?(south, olap03)).to be true
    expect(mod1.rectangular?(olap03)).to be false
    box = mod1.boundedBox(olap03)
    expect(mod1.rectangular?(box)).to be true
    expect(mod1.parallel?(olap03, box)).to be true

    area1 = OpenStudio.getArea(olap03)
    area2 = OpenStudio.getArea(box)
    expect(area1).to_not be_empty
    expect(area2).to_not be_empty
    area1 = area1.get
    area2 = area2.get
    expect((100 * area2 / area1).to_i).to eq(68) # %
    expect(mod1.status).to be_zero

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # Testing more complex cases, e.g. triangular windows, irregular 4-side
    # windows, rough opening edges overlapping parent surface edges. These tests
    # were initially part of the TBD Tests repository (github.com/rd2/tbd_tests),
    # yet have been upgraded and are now tested here.
    model = OpenStudio::Model::Model.new
    space = OpenStudio::Model::Space.new(model)
    space.setName("Space")

    # Windows are SimpleGlazing constructions.
    fen     = OpenStudio::Model::Construction.new(model)
    glazing = OpenStudio::Model::SimpleGlazing.new(model)
    layers  = OpenStudio::Model::MaterialVector.new
    fen.setName("FD fen")
    glazing.setName("FD glazing")
    expect(glazing.setUFactor(2.0)).to be true
    layers << glazing
    expect(fen.setLayers(layers)).to be true

    # Frame & Divider object.
    w000 = 0.000
    w200 = 0.200 # 0mm to 200mm (wide!) around glazing
    fd   = OpenStudio::Model::WindowPropertyFrameAndDivider.new(model)
    fd.setName("FD")
    expect(fd.setFrameConductance(0.500)).to be true
    expect(fd.isFrameWidthDefaulted).to be true
    expect(fd.frameWidth).to be_within(TOL).of(w000)

    # A square base wall surface:
    v0  = OpenStudio::Point3dVector.new
    v0 << OpenStudio::Point3d.new( 0.00, 0.00, 10.00)
    v0 << OpenStudio::Point3d.new( 0.00, 0.00,  0.00)
    v0 << OpenStudio::Point3d.new(10.00, 0.00,  0.00)
    v0 << OpenStudio::Point3d.new(10.00, 0.00, 10.00)

    # A first triangular window:
    v1  = OpenStudio::Point3dVector.new
    v1 << OpenStudio::Point3d.new( 2.00, 0.00, 8.00)
    v1 << OpenStudio::Point3d.new( 1.00, 0.00, 6.00)
    v1 << OpenStudio::Point3d.new( 4.00, 0.00, 9.00)

    # A larger, irregular window:
    v2  = OpenStudio::Point3dVector.new
    v2 << OpenStudio::Point3d.new( 7.00, 0.00, 4.00)
    v2 << OpenStudio::Point3d.new( 4.00, 0.00, 1.00)
    v2 << OpenStudio::Point3d.new( 8.00, 0.00, 2.00)
    v2 << OpenStudio::Point3d.new( 9.00, 0.00, 3.00)

    # A final triangular window, near the wall's upper right corner:
    v3  = OpenStudio::Point3dVector.new
    v3 << OpenStudio::Point3d.new( 9.00, 0.00, 9.80)
    v3 << OpenStudio::Point3d.new( 9.80, 0.00, 9.00)
    v3 << OpenStudio::Point3d.new( 9.80, 0.00, 9.80)

    w0 = OpenStudio::Model::Surface.new(v0, model)
    w1 = OpenStudio::Model::SubSurface.new(v1, model)
    w2 = OpenStudio::Model::SubSurface.new(v2, model)
    w3 = OpenStudio::Model::SubSurface.new(v3, model)
    w0.setName("w0")
    w1.setName("w1")
    w2.setName("w2")
    w3.setName("w3")
    expect(w0.setSpace(space)).to be true
    sub_gross = 0

    [w1, w2, w3].each do |w|
      expect(w.setSubSurfaceType("FixedWindow")).to be true
      expect(w.setSurface(w0)).to be true
      expect(w.setConstruction(fen)).to be true
      expect(w.uFactor).to_not be_empty
      expect(w.uFactor.get).to be_within(0.1).of(2.0)
      expect(w.allowWindowPropertyFrameAndDivider).to be true
      expect(w.setWindowPropertyFrameAndDivider(fd)).to be true
      width = w.windowPropertyFrameAndDivider.get.frameWidth
      expect(width).to be_within(TOL).of(w000)

      sub_gross += w.grossArea
    end

    expect(w1.grossArea).to be_within(TOL).of(1.50)
    expect(w2.grossArea).to be_within(TOL).of(6.00)
    expect(w3.grossArea).to be_within(TOL).of(0.32)
    expect(w0.grossArea).to be_within(TOL).of(100.00)
    expect(w1.netArea).to be_within(TOL).of(w1.grossArea)
    expect(w2.netArea).to be_within(TOL).of(w2.grossArea)
    expect(w3.netArea).to be_within(TOL).of(w3.grossArea)
    expect(w0.netArea).to be_within(TOL).of(w0.grossArea - sub_gross)

    # Applying 2 sets of alterations:
    #   - without, then with Frame & Dividers (F&D)
    #   - 3 successive 20° rotations around:
    angle  = Math::PI / 9
    origin = OpenStudio::Point3d.new(0, 0, 0)
    east   = OpenStudio::Point3d.new(1, 0, 0) - origin
    up     = OpenStudio::Point3d.new(0, 0, 1) - origin
    north  = OpenStudio::Point3d.new(0, 1, 0) - origin

    4.times.each do |i| # successive rotations
      unless i.zero?
        r = OpenStudio.createRotation(origin,  east, angle) if i == 1
        r = OpenStudio.createRotation(origin,    up, angle) if i == 2
        r = OpenStudio.createRotation(origin, north, angle) if i == 3
        expect(w0.setVertices(r.inverse * w0.vertices)).to be true
        expect(w1.setVertices(r.inverse * w1.vertices)).to be true
        expect(w2.setVertices(r.inverse * w2.vertices)).to be true
        expect(w3.setVertices(r.inverse * w3.vertices)).to be true
      end

      2.times.each do |j| # F&D
        if j.zero?
          wx = w000
          fd.resetFrameWidth unless i.zero?
        else
          wx = w200
          expect(fd.setFrameWidth(wx)).to be true

          [w1, w2, w3].each do |w|
            width = w.windowPropertyFrameAndDivider.get.frameWidth
            expect(width).to be_within(TOL).of(wx)
          end
        end

        # F&D widths offset window vertices.
        w1o = mod1.offset(w1.vertices, wx, 300)
        w2o = mod1.offset(w2.vertices, wx, 300)
        w3o = mod1.offset(w3.vertices, wx, 300)

        w1o_m2 = OpenStudio.getArea(w1o)
        w2o_m2 = OpenStudio.getArea(w2o)
        w3o_m2 = OpenStudio.getArea(w3o)
        expect(w1o_m2).to_not be_empty
        expect(w2o_m2).to_not be_empty
        expect(w3o_m2).to_not be_empty
        w1o_m2 = w1o_m2.get
        w2o_m2 = w2o_m2.get
        w3o_m2 = w3o_m2.get

        if j.zero?
          expect(w1o_m2).to be_within(TOL).of(w1.grossArea) # 1.50 m2
          expect(w2o_m2).to be_within(TOL).of(w2.grossArea) # 6.00 m2
          expect(w3o_m2).to be_within(TOL).of(w3.grossArea) # 0.32 m2
        else
          expect(w1o_m2).to be_within(TOL).of(3.75)
          expect(w2o_m2).to be_within(TOL).of(8.64)
          expect(w3o_m2).to be_within(TOL).of(1.10)
        end

        # All windows entirely fit within the wall (without F&D).
        [w1, w2, w3].each { |w| expect(mod1.fits?(w, w0, true)).to be true }

        # All windows fit within the wall (with F&D).
        [w1o, w2o].each { |w| expect(mod1.fits?(w, w0)).to be true }

        # If F&D frame width == 200mm, w3o aligns along the wall top & side,
        # so not entirely within wall polygon.
        expect(mod1.fits?(w3, w0, true)).to be true
        expect(mod1.fits?(w3o, w0)).to be true
        expect(mod1.fits?(w3o, w0, true)).to be true      if j.zero?
        expect(mod1.fits?(w3o, w0, true)).to be false unless j.zero?

        # None of the windows conflict with each other.
        expect(mod1.overlaps?(w1o, w2o)).to be false
        expect(mod1.overlaps?(w1o, w3o)).to be false
        expect(mod1.overlaps?(w2o, w3o)).to be false
      end
    end

    expect(mod1.status).to be_zero
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

  it "checks line segments, triads & orientation" do
    expect(mod1.reset(DBG)).to eq(DBG)
    expect(mod1.level).to eq(DBG)
    expect(mod1.clean!).to eq(DBG)

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # Basic OpenStudio intersection methods.

    # Enclosed polygon.
    p0 = OpenStudio::Point3d.new(-5, -5, -5)
    p1 = OpenStudio::Point3d.new( 5,  5, -5)
    p2 = OpenStudio::Point3d.new(15, 15, -5)
    p3 = OpenStudio::Point3d.new(15, 25, -5)

    # Independent line segment.
    p4 = OpenStudio::Point3d.new(10,-30, -5)
    p5 = OpenStudio::Point3d.new(10, 10, -5)
    p6 = OpenStudio::Point3d.new(10, 40, -5)

    # Independent point.
    p7 = OpenStudio::Point3d.new(14, 20, -5)
    p8 = OpenStudio::Point3d.new(-9, -9, -5)

    # Stress test 'to_p3Dv'. 4 valid input cases.
    # Valid case #1: a single Point3d.
    vtx = mod1.to_p3Dv(p0)
    expect(vtx).to be_a(OpenStudio::Point3dVector)
    expect(vtx[0]).to eq(p0) # same object ID

    # Valid case #2: a Point3dVector.
    vtxx = OpenStudio::Point3dVector.new
    vtxx << p0
    vtxx << p1
    vtxx << p2
    vtxx << p3
    vtx = mod1.to_p3Dv(vtxx)
    expect(vtx).to be_a(OpenStudio::Point3dVector)
    expect(vtx[ 0]).to eq(p0) # same object ID
    expect(vtx[ 1]).to eq(p1) # same object ID
    expect(vtx[ 2]).to eq(p2) # same object ID
    expect(vtx[-1]).to eq(p3) # same object ID

    # Valid case #3: Surface vertices.
    model = OpenStudio::Model::Model.new
    surface = OpenStudio::Model::Surface.new(vtxx, model)
    expect(surface.vertices).to be_an(Array) # not an OpenStudio::Point3dVector
    expect(surface.vertices.size).to eq(4)
    vtx = mod1.to_p3Dv(vtxx)
    expect(vtx).to be_a(OpenStudio::Point3dVector)
    expect(vtx.size).to eq(4)
    expect(vtx[0]).to eq(p0)
    expect(vtx[1]).to eq(p1)
    expect(vtx[2]).to eq(p2)
    expect(vtx[3]).to eq(p3)

    # Valid case #4: Array.
    vtx = mod1.to_p3Dv([p0, p1, p2, p3])
    expect(vtx).to be_a(OpenStudio::Point3dVector)
    expect(vtx.size).to eq(4)
    expect(vtx[0]).to eq(p0)
    expect(vtx[1]).to eq(p1)
    expect(vtx[2]).to eq(p2)
    expect(vtx[3]).to eq(p3)
    expect(mod1.status).to eq(0)

    # Stress test 'nextUp'. Invalid case.
    m0 = "Invalid 'points (2+)' arg #1 (OSut::nextUp)"
    pt = mod1.nextUp([], p0)
    expect(pt).to be nil
    expect(mod1.warn?).to be true
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m0)
    expect(mod1.clean!).to eq(DBG)

    # Valid case.
    pt = mod1.nextUp([p0, p1, p2, p3], p0)
    expect(pt).to be_a(OpenStudio::Point3d)
    expect(pt).to eq(p1)

    pt = mod1.nextUp([p0, p0, p0], p0)
    expect(pt).to be_a(OpenStudio::Point3d)
    expect(pt).to eq(p0)

    # Stress test 'segments'. Invalid case.
    sgs = mod1.segments(p3)
    expect(sgs).to be_a(OpenStudio::Point3dVectorVector)
    expect(sgs).to be_empty
    expect(mod1.status).to eq(0) # nothing logged

    sgs = mod1.segments([p3, p3])
    expect(sgs).to be_a(OpenStudio::Point3dVectorVector)
    expect(sgs).to be_empty
    expect(mod1.status).to eq(0) # nothing logged

    # Valid case.
    sgs = mod1.segments([p0, p1, p2, p3])
    expect(sgs).to be_a(OpenStudio::Point3dVectorVector)
    expect(sgs.size).to eq(4)
    expect(sgs).to respond_to(:first)
    expect(sgs).to_not respond_to(:last)
    expect(sgs[-1]).to be_an(Array) # not an OpenStudio::Point3dVector

    # Stress test 'uniques'.
    m0 = "'n points' String? expecting Integer (OSut::uniques)"

    # Invalid number case - simply returns entire list of unique points.
    uniks = mod1.uniques([p0, p1, p2, p3], "osut")
    expect(uniks).to be_a(OpenStudio::Point3dVector)
    expect(uniks.size).to eq(4)
    expect(mod1.debug?).to be true
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m0)
    expect(mod1.clean!).to eq(DBG)

    # Valid, basic case.
    uniks = mod1.uniques([p0, p1, p2, p3])
    expect(uniks).to be_a(OpenStudio::Point3dVector)
    expect(uniks.size).to eq(4)

    uniks = mod1.uniques([p0, p1, p2, p3], 0)
    expect(uniks).to be_a(OpenStudio::Point3dVector)
    expect(uniks.size).to eq(4)

    # Valid, first 3 points.
    uniks = mod1.uniques([p0, p1, p2, p3], 3)
    expect(uniks).to be_a(OpenStudio::Point3dVector)
    expect(uniks.size).to eq(3)

    # Valid, last 3 points.
    uniks = mod1.uniques([p0, p1, p2, p3], -3)
    expect(uniks).to be_a(OpenStudio::Point3dVector)
    expect(uniks.size).to eq(3)

    # Valid, n = 5: returns original 4 uniques points.
    uniks = mod1.uniques([p0, p1, p2, p3], 5)
    expect(uniks).to be_a(OpenStudio::Point3dVector)
    expect(uniks.size).to eq(4)

    # Valid, n = -5: returns original 4 uniques points.
    uniks = mod1.uniques([p0, p1, p2, p3], -5)
    expect(uniks).to be_a(OpenStudio::Point3dVector)
    expect(uniks.size).to eq(4)

    # Stress tests collinears.
    m0 = "'n points' String? expecting Integer (OSut::collinears)"

    # Invalid case - raise DEBUG message, yet returns valid collinears.
    colls = mod1.collinears([p0, p1, p3, p8], "osut")
    expect(colls).to be_a(OpenStudio::Point3dVector)
    expect(colls.size).to eq(1)
    expect(colls[0]).to eq(p0)
    expect(mod1.debug?).to be true
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m0)
    expect(mod1.clean!).to eq(DBG)

    # Valid, basic case
    colls = mod1.collinears([p0, p1, p3, p8])
    expect(colls.size).to eq(1)
    expect(colls[0]).to eq(p0)                     # same object ID
    expect(mod1.same?(colls.first, p0)).to be true # more expensive way

    colls = mod1.collinears([p0, p1, p3, p8], 0)
    expect(colls.size).to eq(1)
    expect(colls[0]).to eq(p0)

    colls = mod1.collinears([p0, p1, p2, p3, p8])
    expect(colls.size).to eq(2)
    expect(colls[ 0]).to eq(p0)
    expect(colls[-1]).to eq(p1)
    expect(mod1.pointAlongSegment?(p0, sgs.first)) # sg is an Array (size = 2)

    # Only 2 collinears, so request for first 3 is ignored.
    colls = mod1.collinears([p0, p1, p2, p3, p8], 3)
    expect(colls.size).to eq(2)
    expect(mod1.same?(colls[0], p0)).to be true
    expect(mod1.same?(colls[1], p1)).to be true

    # First collinear (out of 2).
    collinears = mod1.collinears([p0, p1, p2, p3, p8], 1)
    expect(collinears.size).to eq(1)
    expect(mod1.same?(collinears[0], p0)).to be true

    # Last collinear (out of 2).
    colls = mod1.collinears([p0, p1, p2, p3, p8], -1)
    expect(colls.size).to eq(1)
    expect(mod1.same?(colls[0], p1)).to be true

    # First two vs last two: same result.
    colls = mod1.collinears([p0, p1, p2, p3, p8], -2)
    expect(colls.size).to eq(2)
    expect(mod1.same?(colls[0], p0)).to be true
    expect(mod1.same?(colls[1], p1)).to be true

    # Ignore n request when n.abs > number of actual collinears.
    colls = mod1.collinears([p0, p1, p2, p3, p8], 6)
    expect(colls.size).to eq(2)
    expect(mod1.same?(colls[0], p0)).to be true
    expect(mod1.same?(colls[1], p1)).to be true

    colls = mod1.collinears([p0, p1, p2, p3, p8], -6)
    expect(colls.size).to eq(2)
    expect(mod1.same?(colls[0], p0)).to be true
    expect(mod1.same?(colls[1], p1)).to be true

    # Stress test pointAlongSegment?
    m0 = "'points' String? expecting Array (OSut::to_p3Dv)"

    # Invalid case.
    expect(mod1.pointAlongSegment?(p3, "osut")).to be false
    expect(mod1.debug?).to be true
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to eq(m0)
    expect(mod1.clean!).to eq(DBG)

    # Valid case.
    pts = OpenStudio::Point3dVector.new
    pts << p0
    pts << p1
    expect(mod1.pointAlongSegment?(p3, pts)).to be false

    # CASE a1: 2x end-to-end line segments (returns matching endpoints).
    expect(mod1.lineIntersects?(   [p0, p1], [p1, p2] )).to be true
    pt = mod1.lineIntersection( [p0, p1], [p1, p2] )
    expect(mod1.same?(pt, p1)).to be true

    # CASE a2: as a1, sequence of line segment endpoints doesn't matter.
    expect(mod1.lineIntersects?(   [p1, p0], [p1, p2] )).to be true
    pt = mod1.lineIntersection( [p1, p0], [p1, p2] )
    expect(mod1.same?(pt, p1)).to be true

    # CASE b1: 2x right-angle line segments, with 1x matching at corner.
    expect(mod1.lineIntersects?(   [p1, p2], [p1, p3] )).to be true
    pt = mod1.lineIntersection( [p1, p2], [p2, p3] )
    expect(mod1.same?(pt, p2)).to be true

    # CASE b2: as b1, sequence of segments doesn't matter.
    expect(mod1.lineIntersects?(   [p2, p3], [p1, p2] )).to be true
    pt = mod1.lineIntersection( [p2, p3], [p1, p2] )
    expect(mod1.same?(pt, p2)).to be true

    # CASE c: 2x right-angle line segments, yet disconnected.
    expect(mod1.lineIntersects?(     [p0, p1], [p2, p3] )).to be false
    expect(mod1.lineIntersection( [p0, p1], [p2, p3] )).to be_nil

    # CASE d: 2x connected line segments, acute angle.
    expect(mod1.lineIntersects?(   [p0, p2], [p3, p0] )).to be true
    pt = mod1.lineIntersection( [p0, p2], [p3, p0] )
    expect(mod1.same?(pt, p0)).to be true

    # CASE e1: 2x disconnected line segments, right angle.
    expect(mod1.lineIntersects?(   [p0, p2], [p4, p6] )).to be true
    pt = mod1.lineIntersection( [p0, p2], [p4, p6] )
    expect(mod1.same?(pt, p5)).to be true

    # CASE e2: as e1, sequence of line segment endpoints doesn't matter.
    expect(mod1.lineIntersects?(   [p0, p2], [p6, p4] )).to be true
    pt = mod1.lineIntersection( [p0, p2], [p6, p4] )
    expect(mod1.same?(pt, p5)).to be true

    # Point ENTIRELY within (vs outside) a polygon.
    expect(mod1.pointWithinPolygon?(p0, [p0, p1, p2, p3], true)).to be false
    expect(mod1.pointWithinPolygon?(p1, [p0, p1, p2, p3], true)).to be false
    expect(mod1.pointWithinPolygon?(p2, [p0, p1, p2, p3], true)).to be false
    expect(mod1.pointWithinPolygon?(p3, [p0, p1, p2, p3], true)).to be false
    expect(mod1.pointWithinPolygon?(p4, [p0, p1, p2, p3])).to be false
    expect(mod1.pointWithinPolygon?(p5, [p0, p1, p2, p3])).to be true
    expect(mod1.pointWithinPolygon?(p6, [p0, p1, p2, p3])).to be false
    expect(mod1.pointWithinPolygon?(p7, [p0, p1, p2, p3])).to be true

    expect(mod1.status).to be_zero

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # Test invalid plane.
    vtx  = OpenStudio::Point3dVector.new
    vtx << OpenStudio::Point3d.new(20, 0, 10)
    vtx << OpenStudio::Point3d.new( 0, 0, 10)
    vtx << OpenStudio::Point3d.new( 0, 0,  0)
    vtx << OpenStudio::Point3d.new(20, 1,  0)

    expect(mod1.poly(vtx)).to be_empty
    expect(mod1.status).to eq(ERR)
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to include("Empty 'plane'")
    expect(mod1.clean!).to eq(DBG)


    # Test self-intersecting polygon. If reactivated, OpenStudio logs to stdout:
    # [utilities.Transformation] <1> Cannot compute outward normal for vertices
    # vtx  = OpenStudio::Point3dVector.new
    # vtx << OpenStudio::Point3d.new(20, 0, 10)
    # vtx << OpenStudio::Point3d.new( 0, 0, 10)
    # vtx << OpenStudio::Point3d.new(20, 0,  0)
    # vtx << OpenStudio::Point3d.new( 0, 0,  0)

    # Original polygon remains unaltered.
    # vtx2 = mod1.poly(vtx)
    # expect(mod1.same?(vtx, vtx2)).to be true
    # expect(mod1.status).to eq(0)
    # expect(mod1.clean!).to eq(DBG)

    # Regular polygon, counterclockwise yet not UpperLeftCorner (ULC).
    vtx  = OpenStudio::Point3dVector.new
    vtx << OpenStudio::Point3d.new(20,  0, 10)
    vtx << OpenStudio::Point3d.new( 0,  0, 10)
    vtx << OpenStudio::Point3d.new( 0,  0,  0)

    sgments = mod1.segments(vtx)
    expect(sgments).to be_a(OpenStudio::Point3dVectorVector)
    expect(sgments.size).to eq(3)

    sgments.each_with_index do |sgment, i|
      unless mod1.xyz?(sgment, :x, sgment[0].x)
        vplane = mod1.verticalPlane(sgment[0], sgment[-1])
        expect(vplane).to be_a(OpenStudio::Plane)
      end
    end

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # Test when alignFace switches solution when surfaces are nearly flat,
    # i.e. when dot product of surface normal vs zenith > 0.99.
    #   (see OpenStudio::Transformation.alignFace)
    origin  = OpenStudio::Point3d.new(0,0,0)
    originZ = OpenStudio::Point3d.new(0,0,1)
    zenith  = originZ - origin

    # 1st surface, nearly horizontal.
    vtx  = OpenStudio::Point3dVector.new
    vtx << OpenStudio::Point3d.new( 2,10, 0.0)
    vtx << OpenStudio::Point3d.new( 6, 4, 0.0)
    vtx << OpenStudio::Point3d.new( 8, 8, 0.5)
    normal = OpenStudio.getOutwardNormal(vtx).get
    expect(zenith.dot(normal).abs).to be > 0.99
    expect(mod1.facingUp?(vtx)).to be true

    aligned = mod1.poly(vtx, false, false, false, true, :ulc).to_a
    matches = aligned.select { |pt| mod1.same?(pt, origin) }
    expect(matches).to be_empty

    # 2nd surface (nearly identical, yet too slanted to be flat.
    vtx  = OpenStudio::Point3dVector.new
    vtx << OpenStudio::Point3d.new( 2,10, 0.0)
    vtx << OpenStudio::Point3d.new( 6, 4, 0.0)
    vtx << OpenStudio::Point3d.new( 8, 8, 0.6)
    normal = OpenStudio.getOutwardNormal(vtx).get
    expect(zenith.dot(normal).abs).to be < 0.99
    expect(mod1.facingUp?(vtx)).to be false

    aligned = mod1.poly(vtx, false, false, false, true, :ulc).to_a
    matches = aligned.select { |pt| mod1.same?(pt, origin) }
    expect(matches).to_not be_empty
    expect(matches.size).to eq(1)

    expect(mod1.status).to be_zero
  end

  it "checks ULC & BLC" do
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

    t     = OpenStudio::Transformation.alignFace(vtx)
    a_vtx = t.inverse * vtx

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
    blc_a_vtx = mod1.blc(a_vtx)
    ulc_vtx   = t * ulc_a_vtx
    blc_vtx   = t * blc_a_vtx
    expect(ulc_vtx[1].x.abs).to be < TOL
    expect(ulc_vtx[1].y.abs).to be < TOL
    expect(ulc_vtx[1].z.abs).to be < TOL
    expect(blc_vtx[0].x.abs).to be < TOL
    expect(blc_vtx[0].y.abs).to be < TOL
    expect(blc_vtx[0].z.abs).to be < TOL
    # puts ulc_vtx
    # [ 0, 0, 10]
    # [ 0, 0,  0]
    # [20, 0,  0]
    # [20, 0, 10]
    # puts blc_vtx
    # [ 0, 0,  0]
    # [20, 0,  0]
    # [20, 0, 10]
    # [ 0, 0, 10]

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # Same, yet (0,0,0) is at index == 0.
    vtx  = OpenStudio::Point3dVector.new
    vtx << OpenStudio::Point3d.new( 0, 0,  0)
    vtx << OpenStudio::Point3d.new(20, 0,  0)
    vtx << OpenStudio::Point3d.new(20, 0, 10)
    vtx << OpenStudio::Point3d.new( 0, 0, 10)

    t     = OpenStudio::Transformation.alignFace(vtx)
    a_vtx = t.inverse * vtx

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
    blc_a_vtx = mod1.blc(a_vtx)
    ulc_vtx   = t * ulc_a_vtx
    blc_vtx   = t * blc_a_vtx
    expect(ulc_vtx[1].x.abs).to be < TOL
    expect(ulc_vtx[1].y.abs).to be < TOL
    expect(ulc_vtx[1].z.abs).to be < TOL
    expect(blc_vtx[0].x.abs).to be < TOL
    expect(blc_vtx[0].y.abs).to be < TOL
    expect(blc_vtx[0].z.abs).to be < TOL
    # puts ulc_vtx
    # [ 0, 0, 10]
    # [ 0, 0,  0]
    # [20, 0,  0]
    # [20, 0, 10]
    # puts blc_vtx
    # [ 0, 0,  0]
    # [20, 0,  0]
    # [20, 0, 10]
    # [ 0, 0, 10]

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # Irregular polygon, no point at 0,0,0.
    vtx = OpenStudio::Point3dVector.new
    vtx << OpenStudio::Point3d.new(18, 0, 10)
    vtx << OpenStudio::Point3d.new( 2, 0, 10)
    vtx << OpenStudio::Point3d.new( 0, 0,  6)
    vtx << OpenStudio::Point3d.new( 0, 0,  4)
    vtx << OpenStudio::Point3d.new( 2, 0,  0)
    vtx << OpenStudio::Point3d.new(18, 0,  0)
    vtx << OpenStudio::Point3d.new(20, 0,  4)
    vtx << OpenStudio::Point3d.new(20, 0,  6)

    t     = OpenStudio::Transformation.alignFace(vtx)
    a_vtx = t.inverse * vtx

    # 1. Native ULC reordering.
    ulc_a_vtx = OpenStudio.reorderULC(a_vtx)
    ulc_vtx   = t * ulc_a_vtx
    # puts ulc_vtx
    # [18, 0,  0]
    # [20, 0,  4]
    # [20, 0,  6]
    # [18, 0, 10]
    # [ 2, 0, 10]
    # [ 0, 0,  6]
    # [ 0, 0,  4]
    # [ 2, 0,  0] ... consistent pattern with previous cases, yet ULC?

    # 2. OSut ULC reordering.
    ulc_a_vtx = mod1.ulc(a_vtx)
    blc_a_vtx = mod1.blc(a_vtx)
    iN = mod1.nearest(ulc_a_vtx)
    iF = mod1.farthest(ulc_a_vtx)
    expect(iN).to eq(2)
    expect(iF).to eq(6)
    ulc_vtx   = t * ulc_a_vtx
    blc_vtx   = t * blc_a_vtx
    expect(mod1.same?(ulc_vtx[2], ulc_vtx[iN])).to be true
    expect(mod1.same?(blc_vtx[1], ulc_vtx[iN])).to be true
    # puts ulc_vtx
    # [ 0, 0,  6]
    # [ 0, 0,  4]
    # [ 2, 0,  0]
    # [18, 0,  0]
    # [20, 0,  4]
    # [20, 0,  6]
    # [18, 0, 10]
    # [ 2, 0, 10]
    # puts blc_vtx
    # [ 0, 0,  4]
    # [ 2, 0,  0]
    # [18, 0,  0]
    # [20, 0,  4]
    # [20, 0,  6]
    # [18, 0, 10]
    # [ 2, 0, 10]
    # [ 0, 0,  6]

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    vtx = OpenStudio::Point3dVector.new
    vtx << OpenStudio::Point3d.new(70, 45,  0)
    vtx << OpenStudio::Point3d.new( 0, 45,  0)
    vtx << OpenStudio::Point3d.new( 0,  0,  0)
    vtx << OpenStudio::Point3d.new(70,  0,  0)

    ulc_vtx = mod1.ulc(vtx)
    blc_vtx = mod1.blc(vtx)
    expect(mod1.status).to be_zero
    # puts ulc_vtx
    # [ 0, 45, 0]
    # [ 0,  0, 0]
    # [70,  0, 0]
    # [70, 45, 0]
    # puts blc_vtx
    # [ 0,  0, 0]
    # [70,  0, 0]
    # [70, 45, 0]
    # [ 0, 45, 0]
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
    expect(v).to be_a(OpenStudio::Point3dVector)
    expect(v).to be_empty
    expect(mod1.error?).to be true
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to include("non-collinears < 3")
    expect(mod1.clean!).to eq(INF)

    # 3x non-unique points (not a polygon).
    vtx  = OpenStudio::Point3dVector.new
    vtx << OpenStudio::Point3d.new( 0, 0,10)
    vtx << OpenStudio::Point3d.new( 0, 0,10)
    vtx << OpenStudio::Point3d.new( 0, 0,10)

    v = mod1.poly(vtx)
    expect(v).to be_a(OpenStudio::Point3dVector)
    expect(v).to be_empty
    expect(mod1.error?).to be true
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to include("non-collinears < 3")
    expect(mod1.clean!).to eq(INF)

    # 4th non-planar point (not a polygon).
    vtx  = OpenStudio::Point3dVector.new
    vtx << OpenStudio::Point3d.new( 0, 0,10)
    vtx << OpenStudio::Point3d.new( 0, 0, 0)
    vtx << OpenStudio::Point3d.new(10, 0, 0)
    vtx << OpenStudio::Point3d.new( 0,10,10)

    v = mod1.poly(vtx)
    expect(v).to be_a(OpenStudio::Point3dVector)
    expect(v).to be_empty
    expect(mod1.error?).to be true
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to include("plane")
    expect(mod1.clean!).to eq(INF)

    # 3x unique points (a valid polygon).
    vtx  = OpenStudio::Point3dVector.new
    vtx << OpenStudio::Point3d.new( 0, 0,10)
    vtx << OpenStudio::Point3d.new( 0, 0, 0)
    vtx << OpenStudio::Point3d.new(10, 0, 0)

    v = mod1.poly(vtx)
    expect(v).to be_a(OpenStudio::Point3dVector)
    expect(v.size).to eq(3)
    expect(mod1.status).to be_zero

    # 4th collinear point (collinear permissive).
    vtx << OpenStudio::Point3d.new(20, 0, 0)
    v = mod1.poly(vtx)
    expect(v).to be_a(OpenStudio::Point3dVector)
    expect(v.size).to eq(4)
    expect(mod1.status).to be_zero

    # Intersecting points, e.g. a 'bowtie' (not a valid Openstudio polygon).
    vtx  = OpenStudio::Point3dVector.new
    vtx << OpenStudio::Point3d.new( 0, 0,10)
    vtx << OpenStudio::Point3d.new( 0, 0, 0)
    vtx << OpenStudio::Point3d.new(10, 0,10)
    vtx << OpenStudio::Point3d.new( 0,10, 0)

    v = mod1.poly(vtx)
    expect(v).to be_a(OpenStudio::Point3dVector)
    expect(v).to be_empty
    expect(mod1.error?).to be true
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to include("Empty 'plane' (OSut::poly)")
    expect(mod1.clean!).to eq(INF)

    # Ensure uniqueness & OpenStudio's counterclockwise ULC sequence.
    vtx  = OpenStudio::Point3dVector.new
    vtx << OpenStudio::Point3d.new( 0, 0,10)
    vtx << OpenStudio::Point3d.new( 0, 0, 0)
    vtx << OpenStudio::Point3d.new(10, 0, 0)
    vtx << OpenStudio::Point3d.new(10, 0, 0)

    v = mod1.poly(vtx, false, true, false, false, :ulc)
    expect(v).to be_a(OpenStudio::Point3dVector)
    expect(v.size).to eq(3)
    expect(mod1.same?(vtx[0], v[0])).to be true
    expect(mod1.same?(vtx[1], v[1])).to be true
    expect(mod1.same?(vtx[2], v[2])).to be true
    expect(mod1.status).to be_zero
    expect(mod1.clean!).to eq(INF)

    # Ensure strict non-collinearity (ULC).
    vtx  = OpenStudio::Point3dVector.new
    vtx << OpenStudio::Point3d.new( 0, 0,10)
    vtx << OpenStudio::Point3d.new( 0, 0, 0)
    vtx << OpenStudio::Point3d.new(10, 0, 0)
    vtx << OpenStudio::Point3d.new(20, 0, 0)

    v = mod1.poly(vtx, false, false, true, false, :ulc)
    expect(v).to be_a(OpenStudio::Point3dVector)
    expect(v.size).to eq(3)
    expect(mod1.same?(vtx[0], v[0])).to be true
    expect(mod1.same?(vtx[1], v[1])).to be true
    expect(mod1.same?(vtx[3], v[2])).to be true
    expect(mod1.status).to be_zero
    expect(mod1.clean!).to eq(INF)

    # Ensuring strict non-collinearity also ensures uniqueness (ULC).
    vtx  = OpenStudio::Point3dVector.new
    vtx << OpenStudio::Point3d.new( 0, 0,10)
    vtx << OpenStudio::Point3d.new( 0, 0, 0)
    vtx << OpenStudio::Point3d.new( 0, 0, 0)
    vtx << OpenStudio::Point3d.new(10, 0, 0)
    vtx << OpenStudio::Point3d.new(20, 0, 0)

    v = mod1.poly(vtx, false, false, true, false, :ulc)
    expect(v).to be_a(OpenStudio::Point3dVector)
    expect(v.size).to eq(3)
    expect(mod1.same?(vtx[0], v[0])).to be true
    expect(mod1.same?(vtx[1], v[1])).to be true
    expect(mod1.same?(vtx[4], v[2])).to be true
    expect(mod1.status).to be_zero
    expect(mod1.clean!).to eq(INF)

    # Check for (valid) convexity.
    vtx  = OpenStudio::Point3dVector.new
    vtx << OpenStudio::Point3d.new( 0, 0,10)
    vtx << OpenStudio::Point3d.new( 0, 0, 0)
    vtx << OpenStudio::Point3d.new(20, 0, 0)

    v = mod1.poly(vtx, true)
    expect(v).to be_a(OpenStudio::Point3dVector)
    expect(v.size).to eq(3)
    expect(mod1.status).to be_zero

    # Check for (invalid) convexity.
    vtx << OpenStudio::Point3d.new(1, 0, 1)
    v = mod1.poly(vtx, true)
    expect(v).to be_a(OpenStudio::Point3dVector)
    expect(v).to be_empty
    expect(mod1.status).to be_zero

    # 2nd check for (valid) convexity (with collinear points).
    vtx  = OpenStudio::Point3dVector.new
    vtx << OpenStudio::Point3d.new( 0, 0,10)
    vtx << OpenStudio::Point3d.new( 0, 0, 0)
    vtx << OpenStudio::Point3d.new(10, 0, 0)
    vtx << OpenStudio::Point3d.new(20, 0, 0)

    v = mod1.poly(vtx, true, false, false, false, :ulc)
    expect(v).to be_a(OpenStudio::Point3dVector)
    expect(v.size).to eq(4)
    expect(mod1.same?(vtx[0], v[0])).to be true
    expect(mod1.same?(vtx[1], v[1])).to be true
    expect(mod1.same?(vtx[2], v[2])).to be true
    expect(mod1.same?(vtx[3], v[3])).to be true
    expect(mod1.status).to be_zero

    # 2nd check for (invalid) convexity (with collinear points).
    vtx << OpenStudio::Point3d.new(1, 0, 1)
    v = mod1.poly(vtx, true, false, false, false, :ulc)
    expect(v).to be_a(OpenStudio::Point3dVector)
    expect(v).to be_empty
    expect(mod1.status).to be_zero

    # 3rd check for (valid) convexity (with collinear points), yet returned
    # 3D points vector become 'aligned' & clockwise.
    vtx  = OpenStudio::Point3dVector.new
    vtx << OpenStudio::Point3d.new( 0, 0,10)
    vtx << OpenStudio::Point3d.new( 0, 0, 0)
    vtx << OpenStudio::Point3d.new(10, 0, 0)
    vtx << OpenStudio::Point3d.new(20, 0, 0)

    v = mod1.poly(vtx, true, false, false, true, :cw)
    expect(v).to be_a(OpenStudio::Point3dVector)
    expect(v.size).to eq(4)
    expect(mod1.xyz?(v, :z, 0)).to be true
    expect(mod1.clockwise?(v)).to be true
    expect(mod1.status).to be_zero

    # Ensure returned vector remains in original sequence (if unaltered).
    vtx  = OpenStudio::Point3dVector.new
    vtx << OpenStudio::Point3d.new( 0, 0,10)
    vtx << OpenStudio::Point3d.new( 0, 0, 0)
    vtx << OpenStudio::Point3d.new(10, 0, 0)
    vtx << OpenStudio::Point3d.new(20, 0, 0)

    v = mod1.poly(vtx, true, false, false, false, :no)
    expect(v).to be_a(OpenStudio::Point3dVector)
    expect(v.size).to eq(4)
    expect(mod1.same?(vtx[0], v[0])).to be true
    expect(mod1.same?(vtx[1], v[1])).to be true
    expect(mod1.same?(vtx[2], v[2])).to be true
    expect(mod1.same?(vtx[3], v[3])).to be true
    expect(mod1.clockwise?(v)).to be false
    expect(mod1.status).to be_zero

    # Sequence of returned vector if altered (avoid collinearity).
    vtx  = OpenStudio::Point3dVector.new
    vtx << OpenStudio::Point3d.new( 0, 0,10)
    vtx << OpenStudio::Point3d.new( 0, 0, 0)
    vtx << OpenStudio::Point3d.new(10, 0, 0)
    vtx << OpenStudio::Point3d.new(20, 0, 0)

    v = mod1.poly(vtx, true, false, true, false, :no)
    expect(v).to be_a(OpenStudio::Point3dVector)
    expect(v.size).to eq(3)
    expect(mod1.same?(vtx[0], v[0])).to be true
    expect(mod1.same?(vtx[1], v[1])).to be true
    expect(mod1.same?(vtx[3], v[2])).to be true
    expect(mod1.clockwise?(v)).to be false
    expect(mod1.status).to be_zero
  end

  it "checks subsurface insertions on (seb) tilted surfaces" do
    # Examples of how to harness OpenStudio's Boost geometry methods to safely
    # insert subsurfaces along rotated/tilted/slanted host/parent/base surfaces.
    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    translator = OpenStudio::OSVersion::VersionTranslator.new
    expect(mod1.reset(DBG)).to eq(DBG)
    expect(mod1.level).to eq(DBG)
    expect(mod1.clean!).to eq(DBG)

    v     = OpenStudio.openStudioVersion.split(".").join.to_i
    file  = File.join(__dir__, "files/osms/out/seb2.osm")
    path  = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model).to_not be_empty
    model = model.get

    openarea = model.getSpaceByName("Open area 1")
    expect(openarea).to_not be_empty
    openarea = openarea.get

    unless v < 350
      expect(openarea.isEnclosedVolume).to be true
      expect(openarea.isVolumeDefaulted).to be true
      expect(openarea.isVolumeAutocalculated).to be true
    end

    w5 = model.getSurfaceByName("Openarea 1 Wall 5")
    expect(w5).to_not be_empty
    w5 = w5.get

    w5_space = w5.space
    expect(w5_space).to_not be_empty
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
    expect(roof.setSurfaceType("RoofCeiling")).to be true
    expect(roof.setSpace(openarea)).to be true

    # Side-note test: genConstruction --- --- --- --- --- --- --- --- --- --- #
    expect(roof.isConstructionDefaulted).to be true
    lc = roof.construction
    expect(lc).to_not be_empty
    lc = lc.get.to_LayeredConstruction
    expect(lc).to_not be_empty
    lc = lc.get
    c  = mod1.genConstruction(model, {type: :roof, uo: 1 / 5.46})
    expect(mod1.status).to be_zero
    expect(c).to be_a(OpenStudio::Model::LayeredConstruction)
    expect(roof.setConstruction(c)).to be true
    expect(roof.isConstructionDefaulted).to be false
    r1 = mod1.rsi(lc)
    r2 = mod1.rsi(c)
    d1 = mod1.rsi(lc)
    d2 = mod1.rsi(c)
    expect((r1 - r2).abs > 0).to be true
    expect((d1 - d2).abs > 0).to be true
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
    expect(tilt_wall.setSurfaceType("Wall")).to be true
    expect(tilt_wall.setSpace(openarea)).to be true

    # New, left side wall.
    vec  = OpenStudio::Point3dVector.new
    vec << w5_0
    vec << w5_1
    vec << roof_left
    left_wall = OpenStudio::Model::Surface.new(vec, model)
    left_wall.setName("Openarea left side wall")
    expect(left_wall.setSpace(openarea)).to be true

    # New, right side wall.
    vec  = OpenStudio::Point3dVector.new
    vec << w5_3
    vec << roof_right
    vec << w5_2
    right_wall = OpenStudio::Model::Surface.new(vec, model)
    right_wall.setName("Openarea right side wall")
    expect(right_wall.setSpace(openarea)).to be true

    unless v < 350
      expect(openarea.isEnclosedVolume).to be true
      expect(openarea.isVolumeDefaulted).to be true
      expect(openarea.isVolumeAutocalculated).to be true
    end

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
    expect(aligned_tilt_wall).to be_a(Array)
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
    expect(tilt_window1.setSubSurfaceType("FixedWindow")).to be true
    expect(tilt_window1.setSurface(tilt_wall)).to be true

    x    = centerline - 3*width/2 - 0.15 # window to the left of the first one
    vec  = OpenStudio::Point3dVector.new
    vec << OpenStudio::Point3d.new(x,         y,          0)
    vec << OpenStudio::Point3d.new(x,         y - height, 0)
    vec << OpenStudio::Point3d.new(x + width, y - height, 0)
    vec << OpenStudio::Point3d.new(x + width, y,          0)

    tilt_window2 = OpenStudio::Model::SubSurface.new(tr * vec, model)
    tilt_window2.setName("Tilted window (left)")
    expect(tilt_window2.setSubSurfaceType("FixedWindow")).to be true
    expect(tilt_window2.setSurface(tilt_wall)).to be true

    x    = centerline + width/2 + 0.15 # window to the right of the first one
    vec  = OpenStudio::Point3dVector.new
    vec << OpenStudio::Point3d.new(x,         y,          0)
    vec << OpenStudio::Point3d.new(x,         y - height, 0)
    vec << OpenStudio::Point3d.new(x + width, y - height, 0)
    vec << OpenStudio::Point3d.new(x + width, y,          0)

    tilt_window3 = OpenStudio::Model::SubSurface.new(tr * vec, model)
    tilt_window3.setName("Tilted window (right)")
    expect(tilt_window3.setSubSurfaceType("FixedWindow")).to be true
    expect(tilt_window3.setSurface(tilt_wall)).to be true

    # file = File.join(__dir__, "files/osms/out/seb_fen.osm")
    # model.save(file, true)

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # Repeat for 3x skylights. Fetch transform if slanted roof vertices were
    # also to "align". Recover the (default) window construction.
    expect(tilt_window1.isConstructionDefaulted).to be true
    construction = tilt_window1.construction
    expect(construction).to_not be_empty
    construction = construction.get

    tr = OpenStudio::Transformation.alignFace(roof.vertices)
    aligned_roof = tr.inverse * roof.vertices
    expect(aligned_roof).to be_a(Array)

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
    expect(skylight1.setSubSurfaceType("Skylight")).to be true
    expect(skylight1.setConstruction(construction)).to be true
    expect(skylight1.setSurface(roof)).to be true

    x    = centerline - 3*width/2 - 0.15 # skylight to the left of center
    vec  = OpenStudio::Point3dVector.new
    vec << OpenStudio::Point3d.new(x,         y + height, 0)
    vec << OpenStudio::Point3d.new(x,         y         , 0)
    vec << OpenStudio::Point3d.new(x + width, y         , 0)
    vec << OpenStudio::Point3d.new(x + width, y + height, 0)

    skylight2 = OpenStudio::Model::SubSurface.new(tr * vec, model)
    skylight2.setName("Skylight (left)")
    expect(skylight2.setSubSurfaceType("Skylight")).to be true
    expect(skylight2.setConstruction(construction)).to be true
    expect(skylight2.setSurface(roof)).to be true

    x    = centerline + width/2 + 0.15 # skylight to the right of center
    vec  = OpenStudio::Point3dVector.new
    vec << OpenStudio::Point3d.new(x,         y + height, 0)
    vec << OpenStudio::Point3d.new(x,         y         , 0)
    vec << OpenStudio::Point3d.new(x + width, y         , 0)
    vec << OpenStudio::Point3d.new(x + width, y + height, 0)

    skylight3 = OpenStudio::Model::SubSurface.new(tr * vec, model)
    skylight3.setName("Skylight (right)")
    expect(skylight3.setSubSurfaceType("Skylight")).to be true
    expect(skylight3.setConstruction(construction)).to be true
    expect(skylight3.setSurface(roof)).to be true

    file = File.join(__dir__, "files/osms/out/seb_ext1.osm")
    model.save(file, true)

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # Now test the same result when relying on OSut::addSub.
    file  = File.join(__dir__, "files/osms/out/seb_mod.osm")
    path  = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model).to_not be_empty
    model = model.get

    roof = model.getSurfaceByName("Openarea slanted roof")
    expect(roof).to_not be_empty
    roof = roof.get

    tilt_wall = model.getSurfaceByName("Openarea tilted wall")
    expect(tilt_wall).to_not be_empty
    tilt_wall = tilt_wall.get

    head   = max_y - 0.005
    offset = width + 0.15

    # Add array of 3x windows to tilted wall.
    sub          = {}
    sub[:id    ] = "Tilted window"
    sub[:height] = height
    sub[:width ] = width
    sub[:head  ] = head
    sub[:count ] = 3
    sub[:offset] = offset

    # The simplest argument set for 'addSubs' is:
    expect(mod1.addSubs(tilt_wall, sub)).to be true

    # As the base surface is tilted, OpenStudio's 'alignFace' + 'alignZPrime'
    # behave in a very intuitive manner: there is no point requesting 'addSubs'
    # first realigns and/or concentrates on the polygon's bounded box - the
    # outcome would be the same in all cases, e.g.:
    #
    #   expect(mod1.addSubs(tilt_wall, sub, false, false, true)).to be true
    #   expect(mod1.addSubs(tilt_wall, sub, false, true)).to be true
    expect(mod1.status).to be_zero
    tilted = model.getSubSurfaceByName("Tilted window:0")
    expect(tilted).to_not be_empty
    tilted = tilted.get

    construction   = tilted.construction
    expect(construction).to_not be_empty
    construction   = construction.get
    sub[:assembly] = construction

    sub.delete(:head)
    expect(sub).to_not have_key(:head)
    sub[:id  ] = ""
    sub[:sill] = 0.0 # will be reset to 5mm
    sub[:type] = "Skylight"
    expect(mod1.addSubs(roof, sub)).to be true
    expect(mod1.warn?).to be true
    expect(mod1.logs.size).to eq(2)

    mod1.logs.each do |lg|
      expect(lg[:message].downcase).to include("reset")
      expect(lg[:message].downcase).to include("sill")
    end

    file = File.join(__dir__, "files/osms/out/seb_ext2.osm")
    model.save(file, true)
  end

  it "checks surface width & height" do
    translator = OpenStudio::OSVersion::VersionTranslator.new
    expect(mod1.reset(DBG)).to eq(DBG)
    expect(mod1.level).to eq(DBG)
    expect(mod1.clean!).to eq(DBG)

    # Modified NREL SEB model.
    file  = File.join(__dir__, "files/osms/out/seb_ext2.osm")
    path  = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model).to_not be_empty
    model = model.get

    # Extension holds:
    #   - 2x vertical side walls
    #   - tilted (cantilevered) wall
    #   - sloped roof
    tilted = model.getSurfaceByName("Openarea tilted wall")
    left   = model.getSurfaceByName("Openarea left side wall")
    right  = model.getSurfaceByName("Openarea right side wall")
    expect(tilted).to_not be_empty
    expect(left).to_not be_empty
    expect(right).to_not be_empty
    tilted = tilted.get
    left   = left.get
    right  = right.get

    expect(mod1.facingUp?(tilted)).to be false
    expect(mod1.xyz?(tilted)).to be false

    # Neither wall has coordinates which align with the model grid. Without some
    # transformation (eg alignFace), OSut's 'width' of a given surface is of
    # some utility. A vertical surface's 'height' remains valid/useful.
    w1 = mod1.width(tilted)
    h1 = mod1.height(tilted)
    expect(w1).to be_within(TOL).of(5.69)
    expect(h1).to be_within(TOL).of(2.35)

    # Aligned, a vertical or sloped (or tilted) surface's 'width' and 'height'
    # correctly report what a tape measurement would reveal (from left to right,
    # when looking at the surface perpendicularly).
    t = OpenStudio::Transformation.alignFace(tilted.vertices)
    tilted_aligned = t.inverse * tilted.vertices
    w01 = mod1.width(tilted_aligned)
    h01 = mod1.height(tilted_aligned)
    expect(mod1.facingUp?(tilted_aligned)).to be true
    expect(mod1.xyz?(tilted_aligned)).to be true
    expect(w01).to be_within(TOL).of(5.89)
    expect(h01).to be_within(TOL).of(3.09)

    w2 = mod1.width(left)
    h2 = mod1.height(left)
    expect(w2).to be_within(TOL).of(0.45)
    expect(h2).to be_within(TOL).of(3.35)
    t = OpenStudio::Transformation.alignFace(left.vertices)
    left_aligned = t.inverse * left.vertices
    w02 = mod1.width(left_aligned)
    h02 = mod1.height(left_aligned)
    expect(w02).to be_within(TOL).of(2.24)
    expect(h02).to be_within(TOL).of(h2) # 'height' based on Y-axis (vs Z-axis)

    w3 = mod1.width(right)
    h3 = mod1.height(right)
    expect(w3).to be_within(TOL).of(1.49)
    expect(h3).to be_within(TOL).of(h2) # same as left
    t = OpenStudio::Transformation.alignFace(right.vertices)
    right_aligned = t.inverse * right.vertices
    w03 = mod1.width(right_aligned)
    h03 = mod1.height(right_aligned)
    expect(w03).to be_within(TOL).of(w02) # same as aligned left
    expect(h03).to be_within(TOL).of(h02) # same as aligned left

    expect(mod1.status).to be_zero

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # What if wall vertex sequences were no longer ULC (e.g. URC)?
    vec  = OpenStudio::Point3dVector.new
    vec << tilted.vertices[3]
    vec << tilted.vertices[0]
    vec << tilted.vertices[1]
    vec << tilted.vertices[2]
    expect(tilted.setVertices(vec)).to be true
    expect(mod1.width(tilted)).to be_within(TOL).of(w1)  # same result
    expect(mod1.height(tilted)).to be_within(TOL).of(h1) # same result

    file = File.join(__dir__, "files/osms/out/seb_ext4.osm")
    model.save(file, true)
  end

  it "checks wwr insertions (seb)" do
    translator = OpenStudio::OSVersion::VersionTranslator.new
    expect(mod1.reset(DBG)).to eq(DBG)
    expect(mod1.level).to eq(DBG)
    expect(mod1.clean!).to eq(DBG)

    wwr   = 0.10
    file  = File.join(__dir__, "files/osms/out/seb_ext2.osm")
    path  = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model).to_not be_empty
    model = model.get

    # Fetch "Openarea Wall 3".
    wall3 = model.getSurfaceByName("Openarea 1 Wall 3")
    expect(wall3).to_not be_empty
    wall3 = wall3.get
    area  = wall3.grossArea * wwr

    # Fetch "Openarea Wall 4".
    wall4 = model.getSurfaceByName("Openarea 1 Wall 4")
    expect(wall4).to_not be_empty
    wall4 = wall4.get

    # Fetch transform if wall3 vertices were to 'align'.
    tr      = OpenStudio::Transformation.alignFace(wall3.vertices)
    a_wall3 = tr.inverse * wall3.vertices
    ymax    = a_wall3.map(&:y).max
    xmax    = a_wall3.map(&:x).max
    xmid    = xmax / 2 # centreline

    # Fetch 'head'/'sill' heights of nearby "Sub Surface 1".
    sub1 = model.getSubSurfaceByName("Sub Surface 1")
    expect(sub1).to_not be_empty
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
    expect(mod1.addSubs(wall3, sbz)).to be true
    expect(mod1.status).to be_zero
    sbz = wall3.subSurfaces
    expect(sbz.size).to eq(2)

    sbz.each do |sb|
      expect(sb.grossArea).to be_within(TOL).of(area)
      sb_sill = sb.vertices.map(&:z).min
      sb_head = sb.vertices.map(&:z).max

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
    tr      = OpenStudio::Transformation.alignFace(wall4.vertices)
    a_wall4 = tr.inverse * wall4.vertices
    ymax    = a_wall4.map(&:y).max
    xmax    = a_wall4.map(&:x).max
    xmid    = xmax / 2 # centreline

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
    expect(fd.setFrameWidth(frame)).to be true
    expect(fd.setFrameConductance(2.500)).to be true

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
    expect(mod1.addSubs(wall4, sbz)).to be true
    puts mod1.logs unless mod1.status.zero?
    expect(mod1.status).to be_zero

    # Add another 5x (frame&divider-enabled) fixed windows, from either
    # left- or right-corner of base surfaces. Fetch "Openarea Wall 6".
    wall6 = model.getSurfaceByName("Openarea 1 Wall 6")
    expect(wall6).to_not be_empty
    wall6 = wall6.get

    # Fetch "Openarea Wall 7".
    wall7 = model.getSurfaceByName("Openarea 1 Wall 7")
    expect(wall7).to_not be_empty
    wall7 = wall7.get

    # Fetch 'head'/'sill' heights of nearby "Sub Surface 6".
    sub6 = model.getSubSurfaceByName("Sub Surface 6")
    expect(sub6).to_not be_empty
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

    expect(mod1.addSubs(wall6, [a6])).to be true
    expect(mod1.status).to be_zero

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

    expect(mod1.addSubs(wall7, [a7])).to be true
    expect(mod1.status).to be_zero

    file = File.join(__dir__, "files/osms/out/seb_ext3.osm")
    model.save(file, true)

    # Fetch a (flat) plenum roof surface, and add a single skylight.
    id = "Level 0 Open area 1 ceiling Plenum RoofCeiling"
    ruf1 = model.getSurfaceByName(id)
    expect(ruf1).to_not be_empty
    ruf1 = ruf1.get

    construction = model.getConstructions.select { |cc| cc.isFenestration }
    expect(construction.size).to eq(1)
    construction = construction.first

    a8              = {}
    a8[:id        ] = "ruf skylight"
    a8[:type      ] = "Skylight"
    a8[:count     ] = 1
    a8[:width     ] = 1.2
    a8[:height    ] = 1.2
    a8[:assembly  ] = construction

    expect(mod1.addSubs(ruf1, [a8])).to be true
    expect(mod1.status).to be_zero

    # The plenum roof inherits a single skylight (without any skylight well).
    # See "checks generated skylight wells" to compare "seb_ext3a" vs "seb_sky":
    #   - more sensible alignment of skylight(s) wrt to roof geometry
    #   - automated skylight well generation
    file = File.join(__dir__, "files/osms/out/seb_ext3a.osm")
    model.save(file, true)
  end

  it "checks for space/surface convexity" do
    translator = OpenStudio::OSVersion::VersionTranslator.new
    expect(mod1.reset(DBG)).to eq(DBG)
    expect(mod1.level).to eq(DBG)
    expect(mod1.clean!).to eq(DBG)

    v     = OpenStudio.openStudioVersion.split(".").join.to_i
    file  = File.join(__dir__, "files/osms/in/smalloffice.osm")
    path  = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model).to_not be_empty
    model = model.get
    core  = nil
    attic = nil

    model.getSpaces.each do |space|
      id = space.nameString
      expect(space.isVolumeAutocalculated).to be true        unless v < 350
      expect(space.isCeilingHeightAutocalculated).to be true unless v < 350
      expect(space.isPartofTotalFloorAreaDefaulted).to be false
      expect(space.isFloorAreaDefaulted).to be true          unless v < 350
      expect(space.isFloorAreaAutocalculated).to be true     unless v < 350
      expect(space.partofTotalFloorArea).to be false         if id == "Attic"
      attic = space                                          if id == "Attic"
      next                                                   if id == "Attic"

      # Isolate core as being part of the total floor area (occupied zone) and
      # not having sidelighting.
      expect(space.partofTotalFloorArea).to be true
      next unless space.exteriorWallArea < TOL

      core = space
    end

    core_floor   = core.surfaces.select {|s| s.surfaceType == "Floor"}
    core_ceiling = core.surfaces.select {|s| s.surfaceType == "RoofCeiling"}

    expect(core_floor.size).to eq(1)
    expect(core_ceiling.size).to eq(1)
    core_floor   = core_floor.first
    core_ceiling = core_ceiling.first
    attic_floor  = core_ceiling.adjacentSurface
    expect(attic_floor).to_not be_empty
    attic_floor  = attic_floor.get

    expect(core.nameString).to include("Core")
    # 22.69, 13.46, 0,                        !- X,Y,Z Vertex 1 {m}
    # 22.69,  5.00, 0,                        !- X,Y,Z Vertex 2 {m}
    #  5.00,  5.00, 0,                        !- X,Y,Z Vertex 3 {m}
    #  5.00, 13.46, 0;                        !- X,Y,Z Vertex 4 {m}
    # -----,------,--
    # 17.69 x 8.46 = 149.66 m2
    expect(core.floorArea).to be_within(TOL).of(149.66)
    core_volume = core.floorArea * 3.05
    expect(core_volume).to be_within(TOL).of(core.volume)

    # OpenStudio versions prior to v351 overestimate attic volume (798.41 m3),
    # as they resort to floor area x height.
    expect(attic.volume).to be_within(TOL).of(720.19) unless v < 350
    expect(attic.volume).to be_within(TOL).of(798.41)     if v < 350
    expect(attic.floorArea).to be_within(TOL).of(567.98) # includes overhangs

    expect(mod1.poly(core_floor, true)).to_not be_empty   # convex
    expect(mod1.poly(core_ceiling, true)).to_not be_empty # convex
    expect(mod1.poly(attic_floor, true)).to_not be_empty  # convex
    expect(mod1.status).to be_zero

    # Insert new 'mini' (2m x 2m) floor/ceiling at the centre of the existing
    # core space. Initial insertion resorting strictly to adding leader lines
    # from the initial core floor/ceiling vertices to the new 'mini'
    # floor/ceiling.
    centre = OpenStudio::getCentroid(core_floor.vertices)
    expect(centre).to_not be_empty
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
    expect(mini_floor.setSpace(core)).to be true

    mini_ceiling_vtx = OpenStudio::Point3dVector.new
    mini_ceiling_vtx << OpenStudio::Point3d.new(mini_w, mini_n, 3.05)
    mini_ceiling_vtx << OpenStudio::Point3d.new(mini_w, mini_s, 3.05)
    mini_ceiling_vtx << OpenStudio::Point3d.new(mini_e, mini_s, 3.05)
    mini_ceiling_vtx << OpenStudio::Point3d.new(mini_e, mini_n, 3.05)
    mini_ceiling = OpenStudio::Model::Surface.new(mini_ceiling_vtx, model)
    mini_ceiling.setName("Mini ceiling")
    expect(mini_ceiling.setSpace(core)).to be true

    mini_attic_vtx = OpenStudio::Point3dVector.new
    mini_attic_vtx << OpenStudio::Point3d.new(mini_e, mini_n, 3.05)
    mini_attic_vtx << OpenStudio::Point3d.new(mini_e, mini_s, 3.05)
    mini_attic_vtx << OpenStudio::Point3d.new(mini_w, mini_s, 3.05)
    mini_attic_vtx << OpenStudio::Point3d.new(mini_w, mini_n, 3.05)
    mini_attic = OpenStudio::Model::Surface.new(mini_attic_vtx, model)
    mini_attic.setName("Mini attic")
    expect(mini_attic.setSpace(attic)).to be true

    expect(mini_ceiling.setAdjacentSurface(mini_attic)).to be true
    expect(mini_ceiling.outsideBoundaryCondition).to eq("Surface")
    expect(mini_attic.outsideBoundaryCondition).to eq("Surface")
    expect(mini_ceiling.outsideBoundaryCondition).to eq("Surface")
    expect(mini_ceiling.outsideBoundaryCondition).to eq("Surface")
    expect(mini_ceiling.adjacentSurface).to_not be_empty
    expect(mini_attic.adjacentSurface).to_not be_empty
    expect(mini_ceiling.adjacentSurface.get).to eq(mini_attic)
    expect(mini_attic.adjacentSurface.get).to eq(mini_ceiling)

    # Reset existing core floor, core ceiling & attic floor vertices to
    # accommodate 3x new mini 'holes' (filled in by the 3x new 'mini'
    # surfaces). 'Hole' vertices are defined in the opposite 'winding' of their
    # 'mini' counterparts (e.g. clockwise if the initial vertex sequence is
    # counterclockwise). To ensure valid (core and attic) area & volume
    # calculations (and avoid OpenStudio stdout errors/warnings), append the
    # last vertex of the original surface: each EnergyPlus edge must be
    # referenced (at least) twice (i.e. the 'leader line' between each of the
    # 3x original surfaces and each of the 'mini' holes must be doubled).
    vtx = OpenStudio::Point3dVector.new
    core_floor.vertices.each {|v| vtx << v}
    vtx << mini_floor_vtx[3]
    vtx << mini_floor_vtx[2]
    vtx << mini_floor_vtx[1]
    vtx << mini_floor_vtx[0]
    vtx << mini_floor_vtx[3]
    vtx << vtx[3]
    expect(core_floor.setVertices(vtx)).to be true

    vtx = OpenStudio::Point3dVector.new
    core_ceiling.vertices.each {|v| vtx << v}
    vtx << mini_ceiling_vtx[1]
    vtx << mini_ceiling_vtx[0]
    vtx << mini_ceiling_vtx[3]
    vtx << mini_ceiling_vtx[2]
    vtx << mini_ceiling_vtx[1]
    vtx << vtx[3]
    expect(core_ceiling.setVertices(vtx)).to be true

    vtx = OpenStudio::Point3dVector.new
    attic_floor.vertices.each {|v| vtx << v}
    vtx << mini_attic_vtx[3]
    vtx << mini_attic_vtx[2]
    vtx << mini_attic_vtx[1]
    vtx << mini_attic_vtx[0]
    vtx << mini_attic_vtx[3]
    vtx << vtx[3]
    expect(attic_floor.setVertices(vtx)).to be true

    # Generate (temporary) OSM & IDF:
    file = File.join(__dir__, "files/osms/out/miniX.osm")
    model.save(file, true)

    # file = File.join(__dir__, "files/osms/out/miniX.idf")
    # ft   = OpenStudio::EnergyPlus::ForwardTranslator.new
    # idf  = ft.translateModel(model)
    # idf.save(file, true)

    # Add 2x skylights to attic.
    attic_south = model.getSurfaceByName("Attic_roof_south")
    expect(attic_south).to_not be_empty
    attic_south = attic_south.get

    aligned = mod1.poly(attic_south, false, false, true, true, :ulc)

    side   = 1.2
    offset = side + 1
    head   = mod1.height(aligned) - 0.2
    expect(head).to be_within(TOL).of(10.16)

    sub          = {}
    sub[:id    ] = "South Skylight"
    sub[:type  ] = "Skylight"
    sub[:height] = side
    sub[:width ] = side
    sub[:head  ] = head
    sub[:count ] = 2
    sub[:offset] = offset
    expect(mod1.addSubs(attic_south, [sub])).to be true
    puts mod1.logs unless mod1.status.zero?
    expect(mod1.status).to be_zero

    file = File.join(__dir__, "files/osms/out/mini_test.osm")
    model.save(file, true)

    # file = File.join(__dir__, "files/osms/out/mini_test.idf")
    # ft   = OpenStudio::EnergyPlus::ForwardTranslator.new
    # idf  = ft.translateModel(model)
    # idf.save(file, true)
    # Running OS 3.7.0-rc: Both Attic ZN and Core_ZN ZN (in IDF) have
    # autocalculated volumes:
    #    - Attic ZN   : 720.19 m3
    #    - CORE_ZN ZN : 456.46 m3 (easy-peasy : 149.66 m2 x 3.05 m)
    #
    # NO ISSUES UP TO HERE!
    # [utilities.Polyhedron] <0> Polyhedron is not enclosed in original testing. Trying to add missing colinear points.
    # [utilities.Polyhedron] <0> Polyhedron is not enclosed.
    # [openstudio.model.Space] <0> Object of type 'OS:Space' and named 'Core_ZN' is not enclosed, there are 2 edges that aren't used exactly twice. Falling back to ceilingHeight * floorArea. Volume calculation will be potentially inaccurate.
    # [utilities.Polyhedron] <0> Polyhedron is not enclosed in original testing. Trying to add missing colinear points.
    # [utilities.Polyhedron] <0> Polyhedron is not enclosed.
    # [openstudio.model.Space] <0> Object of type 'OS:Space' and named 'Attic' is not enclosed, there are 1 edges that aren't used exactly twice. Falling back to ceilingHeight * floorArea. Volume calculation will be potentially inaccurate.

    # Re-validating pre-tested areas + volumes, as well as convexity.
    expect(core.floorArea).to be_within(TOL).of(149.66)
    core_volume = core.floorArea * 3.05
    expect(core_volume).to be_within(TOL).of(core.volume)
    # expect(attic.volume).to be_within(TOL).of(720.19) unless v < 350
    expect(attic.volume).to be_within(TOL).of(798.41)     if v < 350
    expect(attic.floorArea).to be_within(TOL).of(567.98) # includes overhangs

    expect(mod1.poly(core_floor, true)).to be_empty   # now concave
    expect(mod1.poly(core_ceiling, true)).to be_empty # now concave
    expect(mod1.poly(attic_floor, true)).to be_empty  # now concave
    expect(mod1.status).to be_zero

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
    expect(ctl.isSolarDistributionDefaulted).to be false
    expect(ctl.shadowCalculation.get).to eq(shd)

    file = File.join(__dir__, "files/osms/out/mini.osm")
    model.save(file, true)
    # Simulation results E+ 23.1 (SutherlandHodgman, PolygonClipping)
    # ... no E+ errors/warnings.
    #
    # office.osm  FullInteriorAndExterior                 248 GJ 3.7 UMH cool
    # mini.osm A  FullInteriorAndExterior                 248 GJ 3.7 UMH cool
    # mini.osm B  FullExteriorWithReflections             249 GJ 3.7 UMH cool
    # mini.osm C  FullInteriorAndExteriorWithReflections  248 GJ 3.7 UMH cool

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
    expect(mini_north.setSpace(core)).to be true
    expect(mini_north.outsideBoundaryCondition).to eq("Outdoors")

    vtx = OpenStudio::Point3dVector.new
    vtx << mini_ceiling_vtx[3]
    vtx << mini_floor_vtx[0]
    vtx << mini_floor_vtx[1]
    vtx << mini_ceiling_vtx[2]
    mini_east = OpenStudio::Model::Surface.new(vtx, model)
    mini_east.setName("Mini east")
    expect(mini_east.setSpace(core)).to be true
    expect(mini_east.outsideBoundaryCondition).to eq("Outdoors")

    vtx = OpenStudio::Point3dVector.new
    vtx << mini_ceiling_vtx[2]
    vtx << mini_floor_vtx[1]
    vtx << mini_floor_vtx[2]
    vtx << mini_ceiling_vtx[1]
    mini_south = OpenStudio::Model::Surface.new(vtx, model)
    mini_south.setName("Mini south")
    expect(mini_south.setSpace(core)).to be true
    expect(mini_south.outsideBoundaryCondition).to eq("Outdoors")

    vtx = OpenStudio::Point3dVector.new
    vtx << mini_ceiling_vtx[1]
    vtx << mini_floor_vtx[2]
    vtx << mini_floor_vtx[3]
    vtx << mini_ceiling_vtx[0]
    mini_west = OpenStudio::Model::Surface.new(vtx, model)
    mini_west.setName("Mini west")
    expect(mini_west.setSpace(core)).to be true
    expect(mini_west.outsideBoundaryCondition).to eq("Outdoors")

    mini_floor.remove
    mini_ceiling.remove
    expect(mini_attic.setOutsideBoundaryCondition("Outdoors")).to be true

    # Re-validating pre-tested areas + volumes.
    expect(core.floorArea).to be_within(TOL).of(149.66 - 4) # -mini m2
    core_volume = core.floorArea * 3.05
    expect(core_volume).to be_within(TOL).of(core.volume)
    # expect(attic.volume).to be_within(TOL).of(720.19) unless v < 350
    expect(attic.volume).to be_within(TOL).of(798.41)     if v < 350
    expect(attic.floorArea).to be_within(TOL).of(567.98) # includes overhangs

    expect(mod1.poly(core_floor, true)).to be_empty   # now concave
    expect(mod1.poly(core_ceiling, true)).to be_empty # now concave
    expect(mod1.poly(attic_floor, true)).to be_empty  # now concave
    expect(mod1.status).to be_zero

    file = File.join(__dir__, "files/osms/out/mini2.osm")
    model.save(file, true)
    # Simulation results E+ 22.2 (SutherlandHodgman, PolygonClipping)
    # ... no E+ errors/warnings.
    #
    # mini2.osm A  FullInteriorAndExterior                 249 GJ 3.7 UMH cool
    # mini2.osm B  FullExteriorWithReflections             250 GJ 3.5 UMH cool
    # mini2.osm C  FullInteriorAndExteriorWithReflections  250 GJ 3.7 UMH cool

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # Mini as an attic "well":
    #   - reintroduce mini floor @Z0 (ground-facing), as part of attic
    #   - remove attic mini floor @Z3.05
    #   - outdoor-facing courtyard walls become attic "well" walls.
    #   - add interzone attic walls around well.
    mini_floor = OpenStudio::Model::Surface.new(mini_floor_vtx, model)
    mini_floor.setName("Mini floor")
    expect(mini_floor.outsideBoundaryCondition).to eq("Ground")
    expect(mini_floor.setSpace(attic)).to be true

    mini_attic.remove

    vtx = OpenStudio::Point3dVector.new
    vtx << mini_ceiling_vtx[1]
    vtx << mini_floor_vtx[2]
    vtx << mini_floor_vtx[1]
    vtx << mini_ceiling_vtx[2]
    well_north = OpenStudio::Model::Surface.new(vtx, model)
    well_north.setName("Well north")
    expect(well_north.setSpace(attic)).to be true

    vtx = OpenStudio::Point3dVector.new
    vtx << mini_ceiling_vtx[0]
    vtx << mini_floor_vtx[3]
    vtx << mini_floor_vtx[2]
    vtx << mini_ceiling_vtx[1]
    well_east = OpenStudio::Model::Surface.new(vtx, model)
    well_east.setName("Well east")
    expect(well_east.setSpace(attic)).to be true

    vtx = OpenStudio::Point3dVector.new
    vtx << mini_ceiling_vtx[3]
    vtx << mini_floor_vtx[0]
    vtx << mini_floor_vtx[3]
    vtx << mini_ceiling_vtx[0]
    well_south = OpenStudio::Model::Surface.new(vtx, model)
    well_south.setName("Well south")
    expect(well_south.setSpace(attic)).to be true

    vtx = OpenStudio::Point3dVector.new
    vtx << mini_ceiling_vtx[2]
    vtx << mini_floor_vtx[1]
    vtx << mini_floor_vtx[0]
    vtx << mini_ceiling_vtx[3]
    well_west = OpenStudio::Model::Surface.new(vtx, model)
    well_west.setName("Well west")
    expect(well_west.setSpace(attic)).to be true

    expect(mini_north.setAdjacentSurface(well_south)).to be true
    expect(mini_east.setAdjacentSurface(well_west)).to be true
    expect(mini_south.setAdjacentSurface(well_north)).to be true
    expect(mini_west.setAdjacentSurface(well_east)).to be true
    expect(mini_north.outsideBoundaryCondition).to eq("Surface")
    expect(mini_east.outsideBoundaryCondition).to eq("Surface")
    expect(mini_south.outsideBoundaryCondition).to eq("Surface")
    expect(mini_west.outsideBoundaryCondition).to eq("Surface")
    expect(well_south.outsideBoundaryCondition).to eq("Surface")
    expect(well_west.outsideBoundaryCondition).to eq("Surface")
    expect(well_south.outsideBoundaryCondition).to eq("Surface")
    expect(well_east.outsideBoundaryCondition).to eq("Surface")
    expect(mini_north.adjacentSurface).to_not be_empty
    expect(mini_east.adjacentSurface).to_not be_empty
    expect(mini_south.adjacentSurface).to_not be_empty
    expect(mini_west.adjacentSurface).to_not be_empty
    expect(well_south.adjacentSurface).to_not be_empty
    expect(well_west.adjacentSurface).to_not be_empty
    expect(well_north.adjacentSurface).to_not be_empty
    expect(well_east.adjacentSurface).to_not be_empty
    expect(mini_north.adjacentSurface.get).to eq(well_south)
    expect(mini_east.adjacentSurface.get).to eq(well_west)
    expect(mini_south.adjacentSurface.get).to eq(well_north)
    expect(mini_west.adjacentSurface.get).to eq(well_east)
    expect(well_south.adjacentSurface.get).to eq(mini_north)
    expect(well_west.adjacentSurface.get).to eq(mini_east)
    expect(well_north.adjacentSurface.get).to eq(mini_south)
    expect(well_east.adjacentSurface.get).to eq(mini_west)

    # Re-validating pre-tested areas + volumes.
    expect(core.floorArea).to be_within(TOL).of(149.66 - 4) # -mini m2
    core_volume = core.floorArea * 3.05
    expect(core_volume).to be_within(TOL).of(core.volume)

    # OpenStudio volume calculations are fixed as of v351.
    expect(attic.volume).to be_within(TOL).of(949.05)                if v < 350
    # expect(attic.volume).to be_within(TOL).of(720.19 + 4 * 3.05) unless v < 350
    expect(attic.floorArea).to be_within(TOL).of(567.98) # includes overhangs

    expect(mod1.poly(core_floor, true)).to be_empty   # now concave
    expect(mod1.poly(core_ceiling, true)).to be_empty # now concave
    expect(mod1.poly(attic_floor, true)).to be_empty  # now concave
    expect(mod1.status).to be_zero

    file = File.join(__dir__, "files/osms/out/mini3.osm")
    model.save(file, true)
    # Simulation results E+ 22.2 (SutherlandHodgman, PolygonClipping)
    # ... no E+ errors/warnings.
    #
    # mini2.osm A  FullInteriorAndExterior                 252 GJ 3.5 UMH cool
    # mini2.osm B  FullExteriorWithReflections             254 GJ 3.3 UMH cool
    # mini2.osm C  FullInteriorAndExteriorWithReflections  254 GJ 3.3 UMH cool
  end

  it "checks for outdoor-facing roofs" do
    translator = OpenStudio::OSVersion::VersionTranslator.new
    expect(mod1.reset(DBG)).to eq(DBG)
    expect(mod1.level).to eq(DBG)
    expect(mod1.clean!).to eq(DBG)

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # CASE 1: Each space has 1x outdoor-facing roof.
    file  = File.join(__dir__, "files/osms/in/5ZoneNoHVAC.osm")
    path  = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model).to_not be_empty
    model = model.get

    spaces = {}
    roofs  = {}

    model.getSpaces.each do |space|
      space.surfaces.each do |s|
        next unless s.surfaceType.downcase == "roofceiling"
        next unless s.outsideBoundaryCondition.downcase == "outdoors"

        expect(spaces).to_not have_key(space.nameString)
        spaces[space.nameString] = s.nameString
      end
    end

    expect(spaces.size).to eq(5)
    # "Story 1 East Perimeter Space"  : "Surface 18"
    # "Story 1 North Perimeter Space" : "Surface 12"
    # "Story 1 Core Space"            : "Surface 30"
    # "Story 1 South Perimeter Space" : "Surface 24"
    # "Story 1 West Perimeter Space"  : "Surface 6"

    model.getSpaces.each do |space|
      rufs = mod1.roofs(space)
      expect(rufs.size).to eq(1)
      ruf = rufs.first
      expect(ruf).to be_a(OpenStudio::Model::Surface)
      roofs[space.nameString] = ruf.nameString
    end

    expect(roofs.size).to eq(spaces.size)

    spaces.each do |id, surface|
      expect(roofs.keys).to include(id)
      expect(roofs[id]).to eq(surface)
    end

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # CASE 2: None of the occupied spaces have outdoor-facing roofs, yet the
    # plenum above has 4x outdoor-facing roofs (each matches 1x space ceiling).
    file  = File.join(__dir__, "files/osms/out/seb2.osm")
    path  = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model).to_not be_empty
    model = model.get

    occupied = []
    spaces   = {}
    roofs    = {}

    model.getSpaces.each do |space|
      next unless space.partofTotalFloorArea

      occupied << space.nameString

      space.surfaces.each do |s|
        next unless s.surfaceType.downcase == "roofceiling"
        next unless s.outsideBoundaryCondition.downcase == "outdoors"

        expect(spaces).to_not have_key(space.nameString)
        spaces[space.nameString] = s.nameString
      end
    end

    expect(occupied.size).to eq(4)
    expect(spaces).to be_empty

    model.getSpaces.each do |space|
      next unless space.partofTotalFloorArea

      rufs = mod1.roofs(space)
      expect(rufs.size).to eq(1)
      ruf = rufs.first
      expect(ruf).to be_a(OpenStudio::Model::Surface)
      roofs[space.nameString] = ruf.nameString
    end

    expect(roofs.size).to eq(4)
    expect(mod1.status).to be_zero

    occupied.each do |o|
      expect(roofs.keys).to include(o)
      expect(roofs[o].downcase).to include("plenum")
    end
  end

  it "checks leader line anchors and polygon inserts" do
    translator = OpenStudio::OSVersion::VersionTranslator.new
    expect(mod1.reset(DBG)).to eq(DBG)
    expect(mod1.level).to eq(DBG)
    expect(mod1.clean!).to eq(DBG)

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    o0  = OpenStudio::Point3d.new( 0,  0,  0)

    # A larger polygon (s0, an upside-down "U"), defined UpperLeftCorner (ULC).
    s0  = OpenStudio::Point3dVector.new
    s0 << OpenStudio::Point3d.new( 2, 16, 20)
    s0 << OpenStudio::Point3d.new( 2,  2, 20)
    s0 << OpenStudio::Point3d.new( 8,  2, 20)
    s0 << OpenStudio::Point3d.new( 8, 10, 20)
    s0 << OpenStudio::Point3d.new(16, 10, 20)
    s0 << OpenStudio::Point3d.new(16,  2, 20)
    s0 << OpenStudio::Point3d.new(20,  2, 20)
    s0 << OpenStudio::Point3d.new(20, 16, 20)

    # Polygon s0 entirely encompasses 4x smaller rectangular polygons, s1 to s4.
    s1  = OpenStudio::Point3dVector.new
    s1 << OpenStudio::Point3d.new( 7,  3, 20)
    s1 << OpenStudio::Point3d.new( 7,  7, 20)
    s1 << OpenStudio::Point3d.new( 5,  7, 20)
    s1 << OpenStudio::Point3d.new( 5,  3, 20)

    s2  = OpenStudio::Point3dVector.new
    s2 << OpenStudio::Point3d.new( 3, 11, 20)
    s2 << OpenStudio::Point3d.new(10, 11, 20)
    s2 << OpenStudio::Point3d.new(10, 15, 20)
    s2 << OpenStudio::Point3d.new( 3, 15, 20)

    s3  = OpenStudio::Point3dVector.new
    s3 << OpenStudio::Point3d.new(12, 13, 20)
    s3 << OpenStudio::Point3d.new(16, 11, 20)
    s3 << OpenStudio::Point3d.new(17, 13, 20)
    s3 << OpenStudio::Point3d.new(13, 15, 20)

    s4  = OpenStudio::Point3dVector.new
    s4 << OpenStudio::Point3d.new(19,  3, 20)
    s4 << OpenStudio::Point3d.new(19,  6, 20)
    s4 << OpenStudio::Point3d.new(17,  6, 20)
    s4 << OpenStudio::Point3d.new(17,  3, 20)

    area0 = OpenStudio.getArea(s0)
    area1 = OpenStudio.getArea(s1)
    area2 = OpenStudio.getArea(s2)
    area3 = OpenStudio.getArea(s3)
    area4 = OpenStudio.getArea(s4)
    expect(area0).to_not be_empty
    expect(area1).to_not be_empty
    expect(area2).to_not be_empty
    expect(area3).to_not be_empty
    expect(area4).to_not be_empty
    area0 = area0.get
    area1 = area1.get
    area2 = area2.get
    area3 = area3.get
    area4 = area4.get
    expect(area0).to be_within(TOL).of(188)
    expect(area1).to be_within(TOL).of(  8)
    expect(area2).to be_within(TOL).of( 28)
    expect(area3).to be_within(TOL).of( 10)
    expect(area4).to be_within(TOL).of(  6)

    # Side tests: index of nearest/farthest box coordinate to grid origin.
    expect(mod1.nearest(s1)).to eq(3)
    expect(mod1.nearest(s2)).to eq(0)
    expect(mod1.nearest(s3)).to eq(0)
    expect(mod1.nearest(s4)).to eq(3)
    expect(mod1.farthest(s1)).to eq(1)
    expect(mod1.farthest(s2)).to eq(2)
    expect(mod1.farthest(s3)).to eq(2)
    expect(mod1.farthest(s4)).to eq(1)

    expect(mod1.nearest(s1, o0)).to eq(3)
    expect(mod1.nearest(s2, o0)).to eq(0)
    expect(mod1.nearest(s3, o0)).to eq(0)
    expect(mod1.nearest(s4, o0)).to eq(3)
    expect(mod1.farthest(s1, o0)).to eq(1)
    expect(mod1.farthest(s2, o0)).to eq(2)
    expect(mod1.farthest(s3, o0)).to eq(2)
    expect(mod1.farthest(s4, o0)).to eq(1)

    # Box-specific grid instructions, i.e. 'subsets'.
    set = []
    set << { box: s1, rows: 1, cols: 2, w0: 1.4, d0: 1.4, dX: 0.2, dY: 0.2 }
    set << { box: s2, rows: 2, cols: 3, w0: 1.4, d0: 1.4, dX: 0.2, dY: 0.2 }
    set << { box: s3, rows: 1, cols: 1, w0: 2.6, d0: 1.4, dX: 0.2, dY: 0.2 }
    set << { box: s4, rows: 1, cols: 1, w0: 2.6, d0: 1.4, dX: 0.2, dY: 0.2 }

    area_s1 = set[0][:rows] * set[0][:cols] * set[0][:w0] * set[0][:d0]
    area_s2 = set[1][:rows] * set[1][:cols] * set[1][:w0] * set[1][:d0]
    area_s3 = set[2][:rows] * set[2][:cols] * set[2][:w0] * set[2][:d0]
    area_s4 = set[3][:rows] * set[3][:cols] * set[3][:w0] * set[3][:d0]
    area_s  = area_s1 + area_s2 + area_s3 + area_s4
    expect(area_s1).to be_within(TOL).of( 3.92)
    expect(area_s2).to be_within(TOL).of(11.76)
    expect(area_s3).to be_within(TOL).of( 3.64)
    expect(area_s4).to be_within(TOL).of( 3.64)
    expect(area_s).to be_within(TOL).of(22.96)

    # Side test.
    ld1 = OpenStudio::Point3d.new(18,  0, 0)
    ld2 = OpenStudio::Point3d.new( 8,  3, 0)
    sg1 = OpenStudio::Point3d.new(12, 14, 0)
    sg2 = OpenStudio::Point3d.new(12,  6, 0)
    expect(mod1.lineIntersection([sg1, sg2], [ld1, ld2])).to be_nil

    # To support multiple polygon inserts within a larger polygon, subset boxes
    # must be first 'aligned' (along a temporary XY plane) in a systematic way
    # to ensure consistent treatment between sequential methods, e.g.:
    t = OpenStudio::Transformation.alignFace(s0)
    s00 = t.inverse * s0
    s01 = t.inverse * s4
    s01.each { |pt| expect(mod1.pointWithinPolygon?(pt, s00, true)).to be true }

    # Reiterating that if one simply 'aligns' an already flat surface, what ends
    # up being considered a BottomLeftCorner (BLC) vs ULC is contingent on how
    # OpenStudio's 'alignFace' rotates the original surface. Although
    # 'alignFace' operates in a systematic and reliable way, its output isn't
    # always intuitive when dealing with flat surfaces. Here, instead of the
    # original upside-down "U" shape of s0, an aligned s00 presents a
    # conventional "U" shape (i.e. 180° rotation).
    #
    # s00.each_with_index { |sv, i| puts "#{sv} ... vs #{s0[i]}" }; puts
    #   [18,  0, 0] ... vs [ 2, 16, 20]
    #   [18, 14, 0] ... vs [ 2,  2, 20]
    #   [12, 14, 0] ... vs [ 8,  2, 20]
    #   [12,  6, 0] ... vs [ 8, 10, 20]
    #   [ 4,  6, 0] ... vs [16, 10, 20]
    #   [ 4, 14, 0] ... vs [16,  2, 20]
    #   [ 0, 14, 0] ... vs [20,  2, 20]
    #   [ 0,  0, 0] ... vs [20, 16, 20]

    # 'Leader line anchors' are required to safely integrate cutouts (in s0) to
    # accommodate subset inserts.
    expect(mod1.genAnchors(s0, set)).to eq(set.size)
    puts mod1.logs unless mod1.status.zero?
    expect(mod1.status).to be_zero

    # To ensure consistent treatment for subsequent operations, 'genAnchors'
    # resequences subset boxes (s1 to s4), once 'aligned' with the larger
    # polygon. Each subset is then 'realigned' with regards to its respective
    # 'bounded box', and finally BLC-sequenced. This is done only once per set
    # - any subsequent calls to 'genAnchors' systematically rely on the first
    # BLC-sequenced box. This is key when generating skylight wells in attics
    # or plenum spaces.
    set.each_with_index do |st, i|
      expect(st).to have_key(:ld)
      expect(st[:ld]).to be_a(Hash)
      expect(st[:ld]).to have_key(s0)
      # puts "SET #{i+1} (#{st[:ld][s0]}):"; puts st[:box]; puts
    end
    #
    # SET 1 ([8, 10, 20]):
    #   [ 5,  7, 20]
    #   [ 5,  3, 20]
    #   [ 7,  3, 20]
    #   [ 7,  7, 20]
    #
    # SET 2 ([2, 16, 20]):
    #   [10, 15, 20]
    #   [ 3, 15, 20]
    #   [ 3, 11, 20]
    #   [10, 11, 20]
    #
    # SET 3 ([16, 10, 20]):
    #   [17, 13, 20]
    #   [13, 15, 20]
    #   [12, 13, 20]
    #   [16, 11, 20]
    #
    # SET 4 ([16, 10, 20]):
    #   [17,  6, 20]
    #   [17,  3, 20]
    #   [19,  3, 20]
    #   [19,  6, 20]

    # Add array of polygon inserts to s0.
    s00 = mod1.genInserts(s0, set)
    puts mod1.logs unless mod1.status.zero?
    expect(mod1.status).to be_zero
    expect(s00).to be_a(OpenStudio::Point3dVector)
    expect(s00.size).to eq(68)

    # s00.each {|ppts| puts ppts}

    area00  = OpenStudio.getArea(s00)
    expect(area00).to_not be_empty
    area00  = area00.get
    expect(area00).to be_within(TOL).of(165.04)
    sX_area = 0

    # Detailed checks of sets.
    set.each_with_index do |st, i|
      expect(st).to have_key(:out)
      expect(st).to have_key(:box)
      expect(st).to have_key(:vts)
      expect(st).to have_key(:vtx)

      st_area = 0

      st[:vts].each do |id, sX|
        area = OpenStudio.getArea(sX)
        expect(area).to_not be_empty
        st_area += area.get
      end

      expect(st_area).to be_within(TOL).of(area_s1) if i == 0
      expect(st_area).to be_within(TOL).of(area_s2) if i == 1
      expect(st_area).to be_within(TOL).of(area_s3) if i == 2
      expect(st_area).to be_within(TOL).of(area_s4) if i == 3

      sX_area += st_area

      # As discussed earlier, box vertex sequencing is key in successfully
      # identifying leader line anchors for each set. Boxes remain unchanged.
      st[:box].each do |pt|
        expect(mod1.same?(st[:box], s1)).to be true if i == 0
        expect(mod1.same?(st[:box], s2)).to be true if i == 1
        expect(mod1.same?(st[:box], s3)).to be true if i == 2
        expect(mod1.same?(st[:box], s4)).to be true if i == 3
      end

      expect(st[:out]).to have_key(:set)
      expect(st[:out]).to have_key(:box)
      expect(st[:out]).to have_key(:bbox)
      expect(st[:out]).to have_key(:t)
      expect(st[:out]).to have_key(:o)
    end

    expect(sX_area).to be_within(TOL).of(area_s)
    expect(area00 + sX_area).to be_within(TOL).of(area0)
    expect(mod1.status).to be_zero
  end

  it "checks generated skylight wells" do
    translator = OpenStudio::OSVersion::VersionTranslator.new
    expect(mod1.reset(DBG)).to eq(DBG)
    expect(mod1.level).to eq(DBG)
    expect(mod1.clean!).to eq(DBG)

    srr     = 0.05
    version = OpenStudio.openStudioVersion.split(".").join.to_i

    file  = File.join(__dir__, "files/osms/in/smalloffice.osm")
    path  = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model).to_not be_empty
    model = model.get

    core  = []
    attic = []

    # Fetch default construction sets.
    oID = "90.1-2010 - SmOffice - ASHRAE 169-2013-3B" # building
    aID = "90.1-2010 -  - Attic - ASHRAE 169-2013-3B" # attic spacetype level
    o_set = model.getDefaultConstructionSetByName(oID)
    a_set = model.getDefaultConstructionSetByName(oID)
    expect(o_set).to_not be_empty
    expect(a_set).to_not be_empty
    o_set = o_set.get
    a_set = a_set.get
    expect(o_set.defaultInteriorSurfaceConstructions).to_not be_empty
    expect(a_set.defaultInteriorSurfaceConstructions).to_not be_empty
    io_set = o_set.defaultInteriorSurfaceConstructions.get
    ia_set = a_set.defaultInteriorSurfaceConstructions.get
    expect(io_set.wallConstruction).to_not be_empty
    expect(ia_set.wallConstruction).to_not be_empty
    io_wall = io_set.wallConstruction.get.to_LayeredConstruction
    ia_wall = ia_set.wallConstruction.get.to_LayeredConstruction
    expect(io_wall).to_not be_empty
    expect(ia_wall).to_not be_empty
    io_wall = io_wall.get
    ia_wall = ia_wall.get
    expect(io_wall).to eq(ia_wall) # 2x drywall layers
    expect(mod1.rsi(io_wall, 0.150)).to be_within(TOL).of(0.31)

    model.getSpaces.each do |space|
      id = space.nameString

      unless space.partofTotalFloorArea
        attic << space
        next
      end

      sidelit = mod1.daylit?(space, true, false)
      toplit  = mod1.daylit?(space, false)
      expect(sidelit).to be true  if id.include?("Perimeter")
      expect(sidelit).to be false if id.include?("Core")
      expect(toplit ).to be false
      core << space if id.include?("Core")
    end

    expect(core.size).to eq(1)
    expect(attic.size).to eq(1)
    core  = core.first
    attic = attic.first
    expect(mod1.plenum?(attic)).to be false
    expect(mod1.unconditioned?(attic)).to be true

    # TOTAL attic roof area, including overhangs.
    roofs  = mod1.facets(attic, "Outdoors", "RoofCeiling")
    rufs   = mod1.roofs(model.getSpaces)
    total1 = roofs.sum(&:grossArea)
    total2 = rufs.sum(&:grossArea)
    expect(total1.round(2)).to eq(total2.round(2))
    expect(total2.round(2)).to eq(598.76)

    # "GROSS ROOF AREA" (GRA), as per 90.1/NECB - excludes roof overhangs (60m2)
    gra1 = mod1.grossRoofArea(model.getSpaces)
    expect(mod1.status).to be_zero
    expect(gra1.round(2)).to eq(538.86)

    # Unless model geometry is too granular (e.g. finely tessellated), the
    # method 'addSkyLights' generates skylight/wells achieving user-required
    # skylight-to-roof ratios (SRR%). The distinction between TOTAL vs GRA is
    # obviously key for SRR% calculations (i.e. denominators).

    # 2x test CASES:
    #   1. UNCONDITIONED (attic, as is)
    #   2. INDIRECTLY-CONDITIONED (e.g. plenum)
    #
    # For testing purposes, only the core zone here is targeted for skylight
    # wells. Context: NECBs and 90.1 require separate SRR% calculations for
    # differently conditioned spaces (SEMI-CONDITIONED vs CONDITIONED).
    # Consider this as practice - see 'addSkyLights' doc.


    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # CASE 1:
    # Retrieve core GRA. As with overhangs, only the attic roof sections
    # directly-above the core are retained for SRR% calculations. Here, the
    # GRA is substantially lower (than previously-calculated gra1). For now,
    # calculated GRA is only valid BEFORE adding skylight wells.
    gra_attic = mod1.grossRoofArea(core)
    expect(gra_attic.round(2)).to eq(157.77)

    # The method returns the GRA, calculated BEFORE adding skylights/wells.
    rm2 = mod1.addSkyLights(core, {srr: srr})
    puts mod1.logs unless mod1.logs.empty?
    expect(rm2.round(2)).to eq(gra_attic.round(2))

    # New core skylight areas. Successfully achieved SRR%.
    core_skies = mod1.facets(core, "Outdoors", "Skylight")
    sky_area1  = core_skies.sum(&:grossArea)
    expect(sky_area1.round(2)).to eq(7.89)
    ratio      = sky_area1 / rm2
    expect(ratio.round(2)).to eq(srr)

    # Reset attic default construction set for insulated interzone walls.
    construction = mod1.genConstruction(model, {type: :partition, uo: 0.3})
    expect(mod1.rsi(construction, 0.150)).to be_within(TOL).of(1/0.3)
    expect(ia_set.setWallConstruction(construction)).to be true
    expect(mod1.status).to be_zero

    file = File.join(__dir__, "files/osms/out/office_attic.osm")
    model.save(file, true)

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # Side test/comment: why does 'addSkylights' return gross roof area?
    # First, retrieving (newly-added) core roofs (i.e. skylight base surfaces).
    rfs1 = mod1.facets(core, "Outdoors", "RoofCeiling")
    tot1 = rfs1.sum(&:grossArea)
    net  = rfs1.sum(&:netArea)
    expect(rfs1.size).to eq(4)
    expect(tot1.round(2)).to eq(9.06) # 4x 2.265 m2
    expect((tot1 - net).round(2)).to eq(sky_area1.round(2))

    # In absence of skylight wells (more importantly, in absence of leader lines
    # anchoring skylight base surfaces), OSut's 'roofs' & 'grossRoofArea'
    # report not only on newly-added base surfaces (or their areas), but also
    # overalpping areas of attic roofs above. Unfortunately, these become
    # unreliable with newly-added skylight wells.
    rfs2 = mod1.roofs(core)
    tot2 = rfs2.sum(&:grossArea)
    expect(tot2.round(2)).to eq(tot1.round(2))
    expect(tot2.round(2)).to eq(mod1.grossRoofArea(core).round(2))

    # Fortunately, the addition of leader lines does not affect how OpenStudio
    # reports surface areas.
    rfs3 = mod1.facets(attic, "Outdoors", "RoofCeiling")
    tot3 = rfs3.sum(&:grossArea)
    expect((tot3 + tot2).round(2)).to eq(total2.round(2)) # 598.76

    # However, as discussed elsewhere (see 'addSkylights'), these otherwise
    # valid areas are often overestimated for SRR% calculations (e.g. when
    # overhangs and soffits are explicitely modelled). It is for this reason
    # 'addSkylights' reports gross roof area BEFORE adding skylight wells. Best
    # if a higher-level application, relying on 'addSkylights' (e.g. an
    # OpenStudio measure), stores its output for subsequent reporting purposes.

    # Deeper dive: Why are OSut's 'roofs' and 'grossRoofArea' unreliable
    # with leader lines? Both rely on OSut's 'overlaps?', itself relying on
    # OpenStudio's 'join' and 'intersect': if neither are successful in joining
    # (or intersecting) 2x polygons (e.g. attic roof vs cast core ceiling),
    # there can be no identifiable overlap. In such cases, both 'roofs' and
    # 'grossRoofArea' ignore overlapping attic roofs. A demo:
    roof_north   = model.getSurfaceByName("Attic_roof_north")
    core_ceiling = model.getSurfaceByName("Core_ZN_ceiling")
    expect(roof_north).to_not be_empty
    expect(core_ceiling).to_not be_empty
    roof_north   = roof_north.get
    core_ceiling = core_ceiling.get

    t  = OpenStudio::Transformation.alignFace(roof_north.vertices)
    up = OpenStudio::Point3d.new(0,0,1) - OpenStudio::Point3d.new(0,0,0)

    a_roof_north   = t.inverse * roof_north.vertices
    a_core_ceiling = t.inverse * core_ceiling.vertices
    c_core_ceiling = mod1.cast(a_core_ceiling, a_roof_north, up)

    north_m2   = OpenStudio.getArea(a_roof_north)
    ceiling_m2 = OpenStudio.getArea(c_core_ceiling)
    expect(north_m2).to_not be_empty
    expect(ceiling_m2).to_not be_empty
    expect(north_m2.get.round(2)).to eq(192.98)
    expect(ceiling_m2.get.round(2)).to eq(133.81)

    # So far so good. Ensure clockwise winding.
    a_roof_north   = a_roof_north.to_a.reverse
    c_core_ceiling = c_core_ceiling.to_a.reverse
    expect(OpenStudio.join(a_roof_north, c_core_ceiling, TOL2)).to be_empty
    expect(OpenStudio.intersect(a_roof_north, c_core_ceiling, TOL)).to be_empty

    # A future revision of OSut's 'roofs' and 'grossRoofArea' would require:
    #   - a new method identifying leader lines amongts surface vertices
    #   - a new method identifying surface cutouts amongst surface vertices
    #   - a method to purge both leader lines and cutouts from surface vertices
    #   - have 'roofs' & 'grossRoofArea' rely on the remaining outer vertices
    #     ... @todo?

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # CASE 2:
    file  = File.join(__dir__, "files/osms/in/smalloffice.osm")
    path  = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model).to_not be_empty
    model = model.get

    core  = model.getSpaceByName("Core_ZN")
    attic = model.getSpaceByName("Attic")
    expect(core).to_not be_empty
    expect(attic).to_not be_empty
    core  = core.get
    attic = attic.get

    # Tag attic as an INDIRECTLY-CONDITIONED space.
    key = "indirectlyconditioned"
    val = core.nameString
    expect(attic.additionalProperties.setFeature(key, val)).to be true
    expect(mod1.plenum?(attic)).to be false
    expect(mod1.unconditioned?(attic)).to be false
    expect(mod1.setpoints(attic)[:heating]).to be_within(TOL).of(21.11)
    expect(mod1.setpoints(attic)[:cooling]).to be_within(TOL).of(23.89)

    # Here, GRA includes ALL plenum roof surfaces (not just vertically-cast
    # areas onto core ceiling). This makes meeting the SRR% of 5% much harder.
    gra_plenum = mod1.grossRoofArea(core)
    expect(gra_plenum.round(2)).to eq(total1.round(2))

    rm2 = mod1.addSkyLights(core, {srr: srr})
    puts mod1.logs unless mod1.logs.empty?
    expect(rm2.round(2)).to eq(total1.round(2))

    # The total skylight area is greater than in CASE 1. Nonetheless, the method
    # is able to meet the requested SRR 5%. This may not be achievable in other
    # circumstances, given the constrained roof/core overlap. Although a plenum
    # vastly larger than the room(s) it serves is rare, it remains certainly
    # problematic for the application of the NECBs.
    core_skies = mod1.facets(core, "Outdoors", "Skylight")
    sky_area2  = core_skies.sum(&:grossArea)
    expect(sky_area2.round(2)).to eq(29.94)
    ratio2     = sky_area2 / rm2
    expect(ratio2.round(2)).to eq(srr.round(2))
    expect(mod1.status).to be_zero

    file = File.join(__dir__, "files/osms/out/office_plenum.osm")
    model.save(file, true)

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # CASE 2b:
    file  = File.join(__dir__, "files/osms/in/smalloffice.osm")
    path  = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model).to_not be_empty
    model = model.get

    core  = model.getSpaceByName("Core_ZN")
    attic = model.getSpaceByName("Attic")
    expect(core).to_not be_empty
    expect(attic).to_not be_empty
    core  = core.get
    attic = attic.get

    # Again, tagging attic as an INDIRECTLY-CONDITIONED space.
    key = "indirectlyconditioned"
    val = core.nameString
    expect(attic.additionalProperties.setFeature(key, val)).to be true
    expect(mod1.plenum?(attic)).to be false
    expect(mod1.unconditioned?(attic)).to be false
    expect(mod1.setpoints(attic)[:heating]).to be_within(TOL).of(21.11)
    expect(mod1.setpoints(attic)[:cooling]).to be_within(TOL).of(23.89)

    gra_plenum = mod1.grossRoofArea(core)
    expect(gra_plenum.round(2)).to eq(total1.round(2))

    # Conflicting argument case: Here, skylight wells must traverse plenums (in
    # this context, :plenum is an all encompassing keyword for any INDIRECTLY-
    # CONDITIONED, unoccupied space). Yet by passing option "plenum: false",
    # the method is instructed to skip "plenum" skylight wells altogether.
    rm2 = mod1.addSkyLights(core, {srr: srr, plenum: false})
    expect(mod1.warn?).to be true
    expect(mod1.logs.size).to eq(1)
    msg = mod1.logs.first[:message]
    expect(msg).to include("Empty 'sets (3)' (OSut::addSkyLights)")
    expect(rm2.round(2)).to eq(total1.round(2))

    core_skies = mod1.facets(core, "Outdoors", "Skylight")
    sky_area2  = core_skies.sum(&:grossArea)
    expect(sky_area2.round(2)).to eq(0.00)
    expect(mod1.clean!).to eq(DBG)

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # SEB case (flat ceiling plenum).
    file  = File.join(__dir__, "files/osms/out/seb2.osm")
    path  = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model).to_not be_empty
    model = model.get

    entry   = model.getSpaceByName("Entry way 1")
    office  = model.getSpaceByName("Small office 1")
    open    = model.getSpaceByName("Open area 1")
    utility = model.getSpaceByName("Utility 1")
    plenum  = model.getSpaceByName("Level 0 Ceiling Plenum")
    expect(entry).to_not be_empty
    expect(office).to_not be_empty
    expect(open).to_not be_empty
    expect(utility).to_not be_empty
    expect(plenum).to_not be_empty
    entry   = entry.get
    office  = office.get
    open    = open.get
    utility = utility.get
    plenum  = plenum.get
    expect(plenum.partofTotalFloorArea).to be false
    expect(mod1.unconditioned?(plenum)).to be false

    # TOTAL plenum roof area (4x surfaces), no overhangs.
    roofs = mod1.facets(plenum, "Outdoors", "RoofCeiling")
    total = roofs.sum(&:grossArea)
    expect(total.round(2)).to eq(82.21)

    # A single plenum above all 4 occupied rooms. Reports same GRA.
    gra_seb1 = mod1.grossRoofArea(model.getSpaces)
    gra_seb2 = mod1.grossRoofArea(entry)
    expect(gra_seb1.round(2)).to eq(gra_seb2.round(2))
    expect(gra_seb1.round(2)).to eq(total.round(2))

    sky_area = srr * total

    # Before adding skylight wells.
    unless version < 350
      [plenum, entry, office, open, utility].each do |sp|
        expect(sp.isEnclosedVolume).to be true
        expect(sp.isVolumeDefaulted).to be true
        expect(sp.isVolumeAutocalculated).to be true
        expect(sp.volume).to be > 0

        zn = sp.thermalZone
        expect(zn).to_not be_empty
        zn = zn.get
        expect(zn.isVolumeDefaulted).to be true
        expect(zn.isVolumeAutocalculated).to be true
        expect(zn.volume).to be_empty
      end
    end

    # The method returns the GRA, calculated BEFORE adding skylights/wells.
    rm2 = mod1.addSkyLights(model.getSpaces, {area: sky_area})
    puts mod1.logs unless mod1.logs.empty?
    expect(rm2.round(2)).to eq(total.round(2))

    entry_skies   = mod1.facets(entry, "Outdoors", "Skylight")
    office_skies  = mod1.facets(office, "Outdoors", "Skylight")
    utility_skies = mod1.facets(utility, "Outdoors", "Skylight")
    open_skies    = mod1.facets(open, "Outdoors", "Skylight")

    expect(entry_skies).to be_empty
    expect(office_skies).to be_empty
    expect(utility_skies).to be_empty
    expect(open_skies.size).to eq(1)
    open_sky = open_skies.first

    skm2 = open_sky.grossArea
    expect((skm2 / rm2).round(2)).to eq(srr)

    # Assign construction to new skylights.
    construction = mod1.genConstruction(model, {type: :skylight, uo: 2.8})
    expect(open_sky.setConstruction(construction)).to be true
    expect(mod1.status).to be_zero

    # No change after adding skylight wells.
    unless version < 350
      [plenum, entry, office, open, utility].each do |sp|
        expect(sp.isEnclosedVolume).to be true
        expect(sp.isVolumeDefaulted).to be true
        expect(sp.isVolumeAutocalculated).to be true
        expect(sp.volume).to be > 0

        zn = sp.thermalZone
        expect(zn).to_not be_empty
        zn = zn.get
        expect(zn.isVolumeDefaulted).to be true
        expect(zn.isVolumeAutocalculated).to be true
        expect(zn.volume).to be_empty
      end
    end

    file = File.join(__dir__, "files/osms/out/seb_sky.osm")
    model.save(file, true)


    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    file  = File.join(__dir__, "files/osms/in/warehouse.osm")
    path  = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model).to_not be_empty
    model = model.get

    model.getSpaces.each do |space|
      id = space.nameString
      next unless space.partofTotalFloorArea

      sidelit = mod1.daylit?(space, true, false)
      toplit  = mod1.daylit?(space, false)
      expect(sidelit).to be true  if id.include?("Office")
      expect(sidelit).to be false if id.include?("Storage")
      expect(toplit ).to be false if id.include?("Office")
      expect(toplit ).to be true  if id.include?("Storage")
    end

    bulk = model.getSpaceByName("Zone3 Bulk Storage")
    fine = model.getSpaceByName("Zone2 Fine Storage")
    expect(bulk).to_not be_empty
    expect(fine).to_not be_empty
    bulk = bulk.get
    fine = fine.get

    # No overhangs/attics. Calculation of roof area for SRR% is more intuitive.
    gra_bulk = mod1.grossRoofArea(bulk)
    gra_fine = mod1.grossRoofArea(fine)

    bulk_roof_m2 = mod1.roofs(bulk).sum(&:grossArea)
    fine_roof_m2 = mod1.roofs(fine).sum(&:grossArea)
    expect(gra_bulk.round(2)).to eq(bulk_roof_m2.round(2))
    expect(gra_fine.round(2)).to eq(fine_roof_m2.round(2))

    # Initial SSR%.
    bulk_skies = mod1.facets(bulk, "Outdoors", "Skylight")
    sky_area1  = bulk_skies.sum(&:grossArea)
    ratio1     = sky_area1 / bulk_roof_m2
    expect(sky_area1.round(2)).to eq(47.57)
    expect(ratio1.round(2)).to eq(0.01)

    srr  = 0.04
    opts = {}
    opts[:srr  ] = srr
    opts[:size ] = 2.4
    opts[:clear] = true
    rm2 = mod1.addSkyLights(bulk, opts)

    bulk_skies = mod1.facets(bulk, "Outdoors", "Skylight")
    sky_area2  = bulk_skies.sum(&:grossArea)
    expect(sky_area2.round(2)).to eq(128.19)
    ratio2     = sky_area2 / rm2
    expect(ratio2.round(2)).to eq(srr)
    expect(mod1.status).to be_zero

    file = File.join(__dir__, "files/osms/out/warehouse_sky.osm")
    model.save(file, true)
  end

  it "checks facet retrieval" do
    translator = OpenStudio::OSVersion::VersionTranslator.new
    expect(mod1.reset(DBG)).to eq(DBG)
    expect(mod1.level).to eq(DBG)
    expect(mod1.clean!).to eq(DBG)

    file   = File.join(__dir__, "files/osms/out/seb_ext2.osm")
    path   = OpenStudio::Path.new(file)
    model  = translator.loadModel(path)
    expect(model).to_not be_empty
    model  = model.get
    spaces = model.getSpaces
    surfs  = model.getSurfaces
    subs   = model.getSubSurfaces
    expect(surfs.size).to eq(59)
    expect(subs.size).to eq(14)

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
    windows    = mod1.facets(spaces, "Outdoors", "FixedWindow")
    skylights  = mod1.facets(spaces, "Outdoors", "Skylight")
    walls      = mod1.facets(spaces, "Outdoors", "Wall")
    northsouth = mod1.facets(spaces, "Outdoors", "Wall", [:north, :south])
    northeast  = mod1.facets(spaces, "Outdoors", "Wall", [:north, :east])
    north      = mod1.facets(spaces, "Outdoors", "Wall", :north)
    floors1a   = mod1.facets(spaces, "Ground", "Floor", :bottom)
    floors1b   = mod1.facets(spaces, "Surface", "Floor") # plenum
    roofs1     = mod1.facets(spaces, "Outdoors", "RoofCeiling", :top)
    roofs2     = mod1.facets(spaces, "Outdoors", "RoofCeiling", :foo)
    expect(windows.size).to eq(11)
    expect(skylights.size).to eq(3)
    expect(walls.size).to eq(28)
    expect(northsouth).to be_empty
    expect(northeast.size).to eq(8)
    expect(north.size).to eq(14)
    expect(floors1a.size).to eq(4)
    expect(floors1b.size).to eq(4)
    expect(roofs1.size).to eq(5)
    expect(roofs2).to be_empty

    # Concise variants, same output. In the SEB model, only floors face "Ground".
    floors2 = mod1.facets(spaces, "Ground", "Floor")
    floors3 = mod1.facets(spaces, "Ground")
    roofs3  = mod1.facets(spaces, "Outdoors", "RoofCeiling")
    expect(floors2).to eq(floors1a)
    expect(floors3).to eq(floors1a)
    expect(roofs3).to eq(roofs1)

    # Dropping filters, 'envelope' includes all above-grade envelope surfaces.
    nb       = walls.size + roofs3.size + windows.size + skylights.size
    floors4  = mod1.facets(spaces, "ALL", "Floor")
    envelope = mod1.facets(spaces, "Outdoors", "ALL")
    floors1a.each { |fl| expect(floors4.include?(fl)).to be true }
    floors1b.each { |fl| expect(floors4.include?(fl)).to be true }
    expect(envelope.size).to eq(nb)

    # Without arguments, the method returns ALL surfaces and subsurfaces.
    expect(mod1.facets(spaces).size).to eq(surfs.size + subs.size)
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
    expect(mod1.status).to be_zero
    expect(slab).to be_a(OpenStudio::Point3dVector)
    expect(slab.size).to eq(4)

    surface = OpenStudio::Model::Surface.new(slab, model)
    expect(surface).to be_a(OpenStudio::Model::Surface)
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
    expect(mod1.status).to be_zero
    expect(slab).to be_a(OpenStudio::Point3dVector)
    expect(slab.size).to eq(6)

    surface = OpenStudio::Model::Surface.new(slab, model)
    expect(surface).to be_a(OpenStudio::Model::Surface)
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
    expect(mod1.status).to be_zero
    expect(slab).to be_a(OpenStudio::Point3dVector)
    expect(slab.size).to eq(8)

    surface = OpenStudio::Model::Surface.new(slab, model)
    expect(surface).to be_a(OpenStudio::Model::Surface)
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
    expect(mod1.error?).to be true
    msg = mod1.logs.first[:message]
    expect(msg).to eq("Invalid 'plate # 4 (index 3)' (OSut::genSlab)")
    expect(mod1.clean!).to eq(DBG)
    expect(slab).to be_a(OpenStudio::Point3dVector)
    expect(slab).to be_empty

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
    expect(mod1.status).to be_zero
    expect(slab).to be_a(OpenStudio::Point3dVector)
    expect(slab.size).to eq(12)

    surface = OpenStudio::Model::Surface.new(slab, model)
    expect(surface).to be_a(OpenStudio::Model::Surface)
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
    expect(mod1.status).to be_zero
    expect(slab).to be_a(OpenStudio::Point3dVector)
    expect(slab.size).to eq(12)

    surface = OpenStudio::Model::Surface.new(slab, model)
    expect(surface).to be_a(OpenStudio::Model::Surface)
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
    expect(mod1.status).to be_zero
    expect(slab).to be_a(OpenStudio::Point3dVector)
    expect(slab.size).to eq(12)

    surface = OpenStudio::Model::Surface.new(slab, model)
    expect(surface).to be_a(OpenStudio::Model::Surface)
    expect(surface.vertices.size).to eq(12)
    expect(surface.grossArea).to be_within(TOL).of(5 * 20 - 1)

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    # Invalid input case.
    plates = ["osut"]
    slab = mod1.genSlab(plates, z0)
    expect(mod1.debug?).to be true
    expect(mod1.logs.size).to eq(1)
    expect(mod1.logs.first[:message]).to include("String? expecting Hash")
    expect(slab).to be_a(OpenStudio::Point3dVector)
    expect(slab).to be_empty

  end

  it "checks roller shades" do
    translator = OpenStudio::OSVersion::VersionTranslator.new
    expect(mod1.reset(DBG)).to eq(DBG)
    expect(mod1.level).to eq(DBG)
    expect(mod1.clean!).to eq(DBG)

    file   = File.join(__dir__, "files/osms/out/seb_ext4.osm")
    path   = OpenStudio::Path.new(file)
    model  = translator.loadModel(path)
    expect(model).to_not be_empty
    model  = model.get
    spaces = model.getSpaces

    slanted   = mod1.facets(spaces, "Outdoors", "RoofCeiling", [:top, :north])
    expect(slanted.size).to eq(1)
    slanted   = slanted.first
    expect(slanted.nameString).to eq("Openarea slanted roof")
    skylights = slanted.subSurfaces

    tilted  = mod1.facets(spaces, "Outdoors", "Wall", :bottom)
    expect(tilted.size).to eq(1)
    tilted  = tilted.first
    expect(tilted.nameString).to eq("Openarea tilted wall")
    windows = tilted.subSurfaces

    # 2x control groups:
    #   - 3x windows as a single control group
    #   - 3x skylight as another single control group
    skies = OpenStudio::Model::SubSurfaceVector.new
    wins  = OpenStudio::Model::SubSurfaceVector.new
    skylights.each { |sub| skies << sub }
    windows.each   { |sub| wins  << sub }

    if OpenStudio.openStudioVersion.split(".").join.to_i < 321
      expect(mod1.genShade(skies)).to be false
      expect(mod1.status).to be_zero
    else
      expect(mod1.genShade(skies)).to be true
      expect(mod1.genShade(wins)).to be true
      expect(mod1.status).to be_zero
      ctls = model.getShadingControls
      expect(ctls.size).to eq(2)

      ctls.each do |ctl|
        expect(ctl.shadingType).to eq("InteriorShade")
        type = "OnIfHighOutdoorAirTempAndHighSolarOnWindow"
        expect(ctl.shadingControlType).to eq(type)
        expect(ctl.isControlTypeValueNeedingSetpoint1).to be true
        expect(ctl.isControlTypeValueNeedingSetpoint2).to be true
        expect(ctl.isControlTypeValueAllowingSchedule).to be true
        expect(ctl.isControlTypeValueRequiringSchedule).to be false
        spt1 = ctl.setpoint
        spt2 = ctl.setpoint2
        expect(spt1).to_not be_empty
        expect(spt2).to_not be_empty
        spt1 = spt1.get
        spt2 = spt2.get
        expect(spt1).to be_within(TOL).of(18)
        expect(spt2).to be_within(TOL).of(100)
        expect(ctl.multipleSurfaceControlType).to eq("Group")

        ctl.subSurfaces.each do |sub|
          surface = sub.surface
          expect(surface).to_not be_empty
          surface = surface.get
          expect([slanted, tilted]).to include(surface)
        end
      end
    end

    file = File.join(__dir__, "files/osms/out/seb_ext5.osm")
    model.save(file, true)
  end

  it "checks space height & width" do
    translator = OpenStudio::OSVersion::VersionTranslator.new
    expect(mod1.reset(DBG)).to eq(DBG)
    expect(mod1.level).to eq(DBG)
    expect(mod1.clean!).to eq(DBG)

    file  = File.join(__dir__, "files/osms/in/warehouse.osm")
    path  = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model).to_not be_empty
    model = model.get

    fine = model.getSpaceByName("Zone2 Fine Storage")
    expect(fine).to_not be_empty
    fine = fine.get

    # The Fine Storage space has 2 floors, at different Z-axis levels:
    # - main ground floor (slab on grade), Z=0.00m
    # - mezzanine floor, adjacent to the office space ceiling below, Z=4.27m
    expect(mod1.facets(fine, "all", "floor").size).to eq(2)
    groundfloor = model.getSurfaceByName("Fine Storage Floor")
    mezzanine   = model.getSurfaceByName("Office Roof Reversed")
    expect(groundfloor).to_not be_empty
    expect(mezzanine).to_not be_empty
    groundfloor = groundfloor.get
    mezzanine   = mezzanine.get

    # The ground floor is L-shaped, floor surfaces have differenet Z=axis
    # levels, etc. In the context of codes/standards like ASHRAE 90.1 or the
    # Canadian NECB, determining what constitutes a space's 'height' and/or
    # 'width' matters, namely with regards to geometry-based LPD rules (e.g.
    # adjustments based on corridor 'width'). Not stating here what the
    # definitive answers should be in all cases. There are however a few OSut
    # functions that may be helpful.
    #
    # OSut's 'aligned' height and width functions were initially developed for
    # non-flat surfaces, like walls and sloped roofs - particularly useful when
    # such surfaces are rotated in 3D space. It's somewhat less intuitive when
    # applied to horizontal surfaces like floors. In a nutshell, the functions
    # lay out the surface in a 2D grid, aligning it along its 'bounded box'. It
    # then determines a bounding box around the surface, once aligned:
    #   - 'aligned height' designates the narrowest edge of the bounding box
    #   - 'aligned width' designates the widest edge of the bounding box
    #
    # Useful? In some circumstances, maybe. One can argue that these may be of
    # limited use for width-based LPD adjustment calculations.
    expect(mod1.alignedHeight(groundfloor)).to be_within(TOL).of(30.48)
    expect(mod1.alignedWidth(groundfloor)).to be_within(TOL).of(45.72)
    expect(mod1.alignedHeight(mezzanine)).to be_within(TOL).of(9.14)
    expect(mod1.alignedWidth(mezzanine)).to be_within(TOL).of(25.91)

    # OSut's 'spaceHeight' and 'spaceWidth' are more suitable for height- or
    # width-based LPD adjustement calculations. OSut sets a space's width as
    # the length of the narrowest edge of the largest bounded box that fits
    # within a collection of neighbouring floor surfaces. This is considered
    # reasonable for a long corridor, with varying widths along its full
    # length (e.g. occasional alcoves).
    #
    # Achtung! The function can be time consuming (multiple iterations) for
    # very convoluted spaces (e.g. long corridors with multiple concavities).
    expect(mod1.spaceHeight(fine)).to be_within(TOL).of(8.53)
    expect(mod1.spaceWidth(fine)).to be_within(TOL).of(21.33)

    # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
    file  = File.join(__dir__, "files/osms/out/seb_sky.osm")
    path  = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model).to_not be_empty
    model = model.get

    openarea = model.getSpaceByName("Open area 1")
    expect(openarea).to_not be_empty
    openarea = openarea.get

    floor = mod1.facets(openarea, "all", "floor")
    expect(floor.size).to eq(1)
    floor = floor.first

    expect(mod1.alignedHeight(floor)).to be_within(TOL).of(6.88)
    expect(mod1.alignedWidth(floor)).to be_within(TOL).of(8.22)
    expect(mod1.spaceHeight(openarea)).to be_within(TOL).of(3.96)
    expect(mod1.spaceWidth(openarea)).to be_within(TOL).of(3.77)

    expect(mod1.status).to eq(0)
  end
end
