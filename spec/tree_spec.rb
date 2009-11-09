require File.join(File.expand_path(File.dirname(__FILE__)),"spec_helper");

describe "Tree" do
  before(:each) do
    @t = Tree.new
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
    a.length.should == 7
  end
  it "should do a keyscan from a startkey" do
    a = [];
    @t.fold({
      "startkey" => "c"
    }) do |k, v|
      a << k
    end
    a[0].should == "c"
    a[1].should == "d"
    a[2].should == "e"
  end
  it "should do a keyscan from a startkey to an endkey" do
    a = [];
    @t.fold({
      "startkey" => "c",
      "endkey" => "d"
    }) do |k, v|
      a << k
    end
    a[0].should == "c"
    a[1].should == "d"
    a[2].should be_nil
  end
  it "should have inclusive_end=false" do
    a = [];
    @t.fold({
      "startkey" => "c",
      "endkey" => "d",
      "inclusive_end" => "false"
    }) do |k, v|
      a << k
    end
    a[0].should == "c"
    a[1].should be_nil
  end
  it "should do a keyscan from startkey to endkey" do
    a = [];
    @t["Z"] = "foo"
    @t["D"] = "fox"
    @t.fold({
      "startkey" => "B",
      "endkey" => "d"
    }) do |k, v|
      a << k
    end
    a[0].should == "D"
    a.last.should == "d"
    a.length.should == 6
  end
  it "should work with a late startkey" do
    @t["0"] = "x"
    @t["1"] = "x"
    @t["2"] = "x"
    a = []
    @t.fold("startkey" => "c") do |k,v|
      a << k
    end
    a.should == ["c", "d", "e", "f", "g"]
  end
  it "should do a descending keyscan" do
    a = [];
    @t.fold("descending" => "true") do |k, v|
      a << k
    end
    a[0].should == "g"
    a[1].should == "f"
  end
end

describe "mixed-key tree" do
  it "should return proper key objects" do
    t = Tree.new do |a,b|
      if a.class == b.class
        a < b
      else
        a.class < b.class
      end
    end
    t[4] = "ok"
    t["b"] = "bee"
    r = []
    t.fold do |key, value|
      r << key
    end
    r[0].should == 4
    r[1].should == "b"
    t["b"].should == "bee"
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
    @t[0] = "0"
    @t[3] = "3"
    @t["3"] = 3
    s = []
    @t.fold do |k, v|
      s << k
    end
    s[0].should == "3"
    s.last.should == 3
  end
end