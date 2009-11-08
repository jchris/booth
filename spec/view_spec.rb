require File.join(File.expand_path(File.dirname(__FILE__)),"spec_helper");

describe "View" do
  before(:each) do
    @db = Database.new
    @db.put({
      "_id" => "zoo",
      "foo" => "baz"
    })
    # make a map-only view based on the db
    map = "function(doc) { emit(doc.foo, null); };"
    @v = View.new(@db, map)
  end
  it "should emit the doc" do
    result = @v.query
    result[:rows].length.should == 1
    result[:rows].first[:key].should == "baz"
  end
end

# populate the db with collated docs
describe "View with collated docs" do
  before(:each) do
    @db = Database.new
    @keys = [
      nil,
      false, true,
      1, 2, 3.4, 5,
      "a", "A", "aa", "b", "Ba", "bb",
      ["a"], ["b"], ["b","c"], ["b", "c", "a"],
      {"a" => 1}, {"a" => 2}, {"b" => 1}, {"b" => 2},
      {"b" => 2, "a" => 1}, {"b"=> 2, "c"=> 2}
      ]
    
    @keys.reverse.each_with_index do |key, i|
      @db.put({"_id" => i.to_s, "foo" => key})
    end
    
    # make a map-only view based on the db
    map = "function(doc) { emit(doc.foo, null); };"
    @v = View.new(@db, map)
  end
  it "should collate properly" do
    result = @v.query
    result[:rows].each_with_index do |row, i|
      # puts "row #{row.inspect}"
      row[:key].should == @keys[i]
    end
  end
  it "should support key ranges" do
    puts "view key ranges"
    result = @v.query(:startkey => "aa", :endkey => "bb")
    result[:rows].each_with_index do |row, i|
      puts "row #{row.inspect}"
      # row[:key].should == @keys[i]
    end
    result[:rows].length.should == 5
    result[:rows][0].id.should == "9"
  end
  it "should support key lookups" do
    result = @v.query(:key => "aa")
    result[:rows].length.should == 1
    result[:rows][0].id.should == "9"
  end
end