require "osut"

RSpec.describe OSut do
  TOL = 0.01

  let(:cls1) { Class.new  { extend OSut } }
  let(:cls2) { Class.new  { extend OSut } }
  let(:mod1) { Module.new { extend OSut } }
  let(:mod2) { Module.new { extend OSut } }

  it "can access OSut from within class instances" do
    translator = OpenStudio::OSVersion::VersionTranslator.new
    file = File.join(__dir__, "files/osms/in/seb.osm")
    path = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model.empty?).to be(false)
    model = model.get

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

    expect(cls1.status).to eq(OSut::ERROR)
    expect(cls1.logs.size).to eq(2)
    msg = "holds non-StandardOpaqueMaterial(s) (OSut::thickness)"
    cls1.logs.each { |l| expect(l[:message].include?(msg)).to be(true) }

    # OSut, and by extension OSlg, are intended to be accessed "globally"
    # once instantiated within a class or module. Here, class instance cls2
    # accesses the same OSut module methods as cls1.
    expect(cls2.status).to eq(OSut::ERROR)
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

  it "can access OSut from within module instances" do
    # Repeating the same exercice as above, yet with module instances.
    translator = OpenStudio::OSVersion::VersionTranslator.new
    file = File.join(__dir__, "files/osms/in/seb.osm")
    path = OpenStudio::Path.new(file)
    model = translator.loadModel(path)
    expect(model.empty?).to be(false)
    model = model.get

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

    expect(mod1.status).to eq(OSut::ERROR)
    expect(mod1.logs.size).to eq(2)
    msg = "holds non-StandardOpaqueMaterial(s) (OSut::thickness)"
    mod1.logs.each { |l| expect(l[:message].include?(msg)).to be(true) }

    expect(mod2.status).to eq(OSut::ERROR)
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

  it "can retrieve a surfaces default construction set" do
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
      expect(mod1.status).to eq(OSut::ERROR)
      msg = "construction not defaulted (defaultConstructionSet)"
      mod1.logs.each {|l| expect(l[:message].include?(msg)) }
    end
  end
end
