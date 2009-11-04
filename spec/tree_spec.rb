require File.join(File.expand_path(File.dirname(__FILE__)),"spec_helper");

describe "Tree" do
  before(:each) do
    @t = Tree.new do |a,b|
      if a.class == b.class
        a < b
      else
        a.class < b.class
      end
    end
    keys = %w{g d b a f c e}
    keys.each do |x| 
      @t[x] = x * 2;
    end
  end
  it "should return values" do
    @t["f"].should == "ff"
  end
  it "should do a keyscan" do
    a = [];
    @t.fold() do |k, v|
      a << k
    end
    a[0].should == "a"
  end
  it "should do a keyscan from a startkey" do
    a = [];
    @t.fold({
      :startkey => "c"
    }) do |k, v|
      a << k
    end
    a[0].should == "c"
    a[1].should == "d"
    a[2].should == "e"
  end
  it "should do a keyscan from a startkey to and endkey" do
    a = [];
    @t.fold({
      :startkey => "c",
      :endkey => "d "
    }) do |k, v|
      a << k
    end
    a[0].should == "c"
    a[1].should == "d"
    a[2].should be_nil
  end
  it "should do a keyscan from startkey to endkey" do
    a = [];
    @t["Z"] = "foo"
    @t["D"] = "fox"
    @t.fold({
      :startkey => "B",
      :endkey => "d"
    }) do |k, v|
      a << k
    end
    a[0].should == "D"
    a.last.should == "d"
    a.length.should == 6
  end
  it "should do a descending keyscan" do
    a = [];
    @t.fold(:descending => "true") do |k, v|
      a << k
    end
    a[0].should == "g"
    a[1].should == "f"
  end
end

describe "custom tree" do
  before(:each) do
    @t = Tree.new do |a,b|
      if a.class == b.class
        a < b
      else
        a.class < b.class
      end
    end
    keys = %w{g d b a f c e}
    keys.each do |x| 
      @t[x] = x * 2;
    end
  end
  it "should collate properly" do
    pending
    @t[0] = "0"
    @t[3] = "3"
    @t["3"] = 3
    s = []
    @t.fold do |k, v|
      s << k
    end
    s[0].should == 0
    s[2].should == "3"
  end
end