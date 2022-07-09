require "outilities"

RSpec.describe Outilities do
  let(:clss) { Class.new  { extend Outilities } }
  let(:cls2) { Class.new  { extend Outilities } }
  let(:modu) { Module.new { extend Outilities } }

  it "can access utilities within class instances" do
  end
end
