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
  # move rev handling to doc spec
  # it "should apply revs" do
  #   d = @db.get("foo")
  #   d.rev.should_not be_empty
  # end
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
  # it "should fail updates with a bad rev" do
  #   lambda {
  #     @db.put({
  #       "_id" => "foo",
  #       "_rev" => "555",
  #       "bam" => "duck"
  #     })      
  #   }.should raise_error
  # end
  # it "should allow updates with a good rev" do
  #   d = @db.get("foo")
  #   d["bam"].should == "baz"
  #   new_rev = @db.put({
  #     "_id" => "foo",
  #     "_rev" => d.rev,
  #     "bam" => "duck"
  #   })
  #   dx = @db.get("foo")
  #   dx.rev.should == new_rev
  #   new_rev.should != d.rev 
  #   dx["bam"].should == "duck"
  # end
  describe "seq" do
    before(:each) do
      @db.put({
        "_id" => "bar",
        "bam" => "dog"
      })
    end
    it "should increment on doc" do
      d = @db.get("foo")
      d.seq.should == 1
      @db.put({
        "_id" => "foo",
        "_rev" => d.rev,
        "bam" => "duck"
      })
      d = @db.get("foo")
      d.seq.should == 3
    end
    it "should be viewable" do
      a = []
      @db.by_seq({:startkey => 0}) do |k, v|
        a << v.id
      end
      a[0].should == "foo"
      a[1].should == "bar"
    end
    it "should be sparse" do
      d = @db.get("foo")
      d.seq.should == 1
      @db.put({
        "_id" => "foo",
        "_rev" => d.rev,
        "bam" => "duck"
      })
      a = []
      @db.by_seq({:startkey => 0}) do |k, v|
        a << v.id
      end
      a[0].should == "bar"
      a[1].should == "foo"
    end
  end
end