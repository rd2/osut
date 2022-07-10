require "outilities"

RSpec.describe Outilities do
  let(:clss) { Class.new  { extend Outilities } }
  let(:cls2) { Class.new  { extend Outilities } }
  let(:modu) { Module.new { extend Outilities } }

  it "can access utilities within class instances" do
    clss.clean!

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
      th = clss.thickness(c)
      expect(th).to be_within(Outilities::TOL).of(0) if id.include?("Air Wall")
      expect(th).to be_within(Outilities::TOL).of(0) if id.include?("Double pane")
      next if id.include?("Air Wall")
      next if id.include?("Double pane")
      expect(th > 0).to be(true)
    end

    expect(clss.status).to eq(Outilities::ERROR)
    expect(clss.logs.size).to eq(2)
    msg = "holds invalid material(s), Outilities::thickness"
    clss.logs.each { |l| expect(l[:message].include?(msg)).to be(true) }

    cls2.clean!

    model.getConstructions.each do |c|
      next if c.to_LayeredConstruction.empty?
      c = c.to_LayeredConstruction.get
      id = c.nameString
      next if id.include?("Air Wall")
      next if id.include?("Double pane")
      th = cls2.thickness(c)
      expect(th > 0).to be(true)
    end

    expect(cls2.status.zero?).to be(true)
    expect(cls2.logs.empty?).to be(true)
  end

  it "can access utilities within a module" do
    modu.clean!

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
      th = modu.thickness(c)
      expect(th).to be_within(Outilities::TOL).of(0) if id.include?("Air Wall")
      expect(th).to be_within(Outilities::TOL).of(0) if id.include?("Double pane")
      next if id.include?("Air Wall")
      next if id.include?("Double pane")
      expect(th > 0).to be(true)
    end

    expect(modu.status).to eq(Outilities::ERROR)
    expect(modu.logs.size).to eq(2)
    msg = "holds invalid material(s), Outilities::thickness"
    modu.logs.each { |l| expect(l[:message].include?(msg)).to be(true) }
  end
end
