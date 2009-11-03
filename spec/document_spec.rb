require File.join(File.expand_path(File.dirname(__FILE__)),"spec_helper");

describe "Doc" do
  before(:each) do
    @d = Document.new({
      "_id" => "awesome",
      "foo" => "bar"
    })
  end
  it "should have an id" do
    @d.id.should == "awesome"
  end
  it "should have a rev" do
    @d.rev.should_not be_nil    
  end
  it "should have body" do
    @d.body["foo"].should == "bar"    
  end
  describe "updating it with a matching rev" do
    before(:each) do
      @r = @d.rev
      @d.update({
        "_id" => "awesome",
        "_rev" => @r,
        "foo" => "box"
      })
    end
    it "should get a new rev" do
      @d.rev.should_not == @r      
    end
    it "should update fields" do
      @d.body["foo"].should == "box"    
    end
  end
  describe "updating it with a conflict" do
    before(:each) do
      @r = @d.rev
      @d.update({
        "_id" => "awesome",
        "_rev" => @r,
        "foo" => "conflict"
      },{
        :all_or_nothing => "true"
      })
    end
    it "should have conflicts" do
      @d.conflicts.length.should == 1
    end
  end
  it "should have no conflicts" do
    @d.conflicts.should == []
  end
end
