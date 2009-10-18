require File.join(File.expand_path(File.dirname(__FILE__)),"spec_helper");

describe "Database" do
  before(:each) do
    @db = Database.new
  end
  it "should accept docs" do
    @db.put({
      "_id" => "foo",
      "bam" => "baz"
    })
    d = @db.get("foo")
    d.id.should == "foo"
    d["bam"].should == "baz"
  end
end