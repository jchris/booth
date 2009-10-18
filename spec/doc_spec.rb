require File.join(File.expand_path(File.dirname(__FILE__)),"spec_helper");

describe "Doc" do
  before(:each) do
    @d = Doc.new({
      "_id" => "awesome",
      "foo" => "bar"
    })
  end
  it "should have an id" do
    @d.id.should == "awesome"
  end
end