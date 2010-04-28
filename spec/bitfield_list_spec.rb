require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "BitfieldList" do
  class FakeModel
    include BitfieldList
    attr_accessor :fakefield, :realfield
    def initialize
      @fakefield = 0
      @realfield = 0
    end
    def read_attribute(input)
      @realfield
    end
    def write_attribute(field, input)
      @realfield = input
    end
    bitfield :fakefield, %w{foo bar baz}
  end
  
  before(:each) do
    @fm = FakeModel.new
  end
  
  it "should create class methods" do
    @fm.fakefield.should be_instance_of(Array)
  end
  
  it "should add items" do
    @fm.fakefield = "bar"
    @fm.fakefield.should == ["bar"]
    @fm.realfield.should == 2
    
    @fm.fakefield = ["foo", "bar", "baz"]
    @fm.fakefield.should == ["foo", "bar", "baz"]
    @fm.realfield.should == 7
  end
  
  it "should reject invalid flags" do
    lambda {@fm.fakefield = "nosuchflag"}.should raise_exception(ArgumentError)
  end
  
  it "should add string to flag array" do
    @fm.fakefield = "bar"
    @fm.fakefield_add "foo"
    @fm.fakefield.should == ["foo", "bar"]
  end
  
  it "should add array to flag array" do
    @fm.fakefield = "bar"
    @fm.fakefield_add ["foo", "baz"]
    @fm.fakefield.should == ["foo", "bar", "baz"]
  end
  
  it "should remove string from flag array" do
    @fm.fakefield = ["foo", "bar"]
    @fm.fakefield_remove "foo"
    @fm.fakefield.should == ["bar"]
  end
  
  it "should remove array from flag array" do
    @fm.fakefield = ["foo", "bar", "baz"]
    @fm.fakefield_remove ["foo", "baz"]
    @fm.fakefield.should == ["bar"]
  end
  
  it "should detect if a flag has been set" do
    @fm.fakefield = ["foo", "baz"]
    @fm.fakefield_set?("baz").should be_true
    @fm.fakefield_set?("bar").should be_false
  end
  
  it "should return an array of available flags" do
    @fm.fakefield_flaglist.should == ["foo", "bar", "baz"]
  end
end
