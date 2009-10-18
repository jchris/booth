require File.join(File.expand_path(File.dirname(__FILE__)),"spec_helper");

describe "Database" do
  before(:each) do
    @db = Database.new
    @db.put({
      "_id" => "foo",
      "bam" => "baz"
    })
  end
  it "should accept docs" do
    d = @db.get("foo")
    d.id.should == "foo"
    d["bam"].should == "baz"
  end
  it "should apply revs" do
    d = @db.get("foo")
    d.rev.should_not be_empty
  end
  it "should apply a sequence" do
    @db.put({
      "_id" => "bar",
      "bam" => "dog"
    })
    d = @db.get("foo")
    d.seq.should == 1
    d2 = @db.get("bar")
    d2.seq.should == 2
    @db.seq.should == 2
  end
  it "should require revs for updates" do
    
  end
end