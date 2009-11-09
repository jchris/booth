require 'database'
require 'query_server'

class View
  def initialize db, map, reduce = nil
    @db = db
    @map = map
    @reduce = reduce
    @seq = 0
    @index = Tree.new do |a,b|
      # puts "Q a #{a.inspect} b #{b.inspect}"
      r = View.less_json(a, b)
      # puts "R #{r.inspect}"
      r
    end
  end

  # responds to http requests
  # TODO, this should not buffer
  def query p={}, &fun
    updateView
    rows = runQuery(p, &fun)
    {
      :rows => rows
    }
  end
  
  class << self
    # view collation
    def less_json a, b
      # puts "less_json\n  a #{a.inspect}\n  b #{b.inspect}"
      type_a = type_sort(a)
      type_b = type_sort(b)
      # puts "a #{a} type_a #{type_a}"
      if type_a == type_b
        less_same_type(a, b, type_a)
      else
        type_a < type_b
      end
    end
    def type_sort(v)
      case v
      when nil
        0
      when false
        0
      when true
        0
      when Integer
        1
      when Float
        1
      when String
        2
      when Array
        3
      when Hash
        4
      else 
        5
      end
    end
    def less_same_type a, b, type
      case type
      when 0
        atom_sort(a) < atom_sort(b)
      when 2
        less_string(a, b)
      when 3
        less_array(a.clone, b.clone)
      when 4
        less_hash(a, b)
      else
        a < b
      end
    end
    def atom_sort(v)
      case v 
      when nil
        1
      when false
        2
      when true
        3
      end
    end
    def less_array(a, b)
      # puts " less_array(a, b) a #{a.inspect} b #{b.inspect}"
      if a.length == 0 || b.length == 0
        if b.length == 0
          return false
        else
          return true
        end
      end
      
      v_a = a.shift
      v_b = b.shift
      if less_json(v_a, v_b)
        true
      elsif less_json(v_b, v_a)
        false
      else
        less_array(a, b)
      end
    end
    
    def less_hash(a, b)
      aa = a.to_a
      bb = b.to_a
      less_array(aa, bb)
    end
    
    # this should really be using icu for correctness
    # TODO http://github.com/jchris/icu4r
    def less_string(a, b)
      ad = a.downcase 
      bd = b.downcase
      if ad == bd
        # compare with case to approximate ICU
        a > b 
      else
        ad < bd
      end
    end
  end
  
  # implementation functions
  private
  
  def updateView
    QueryServer.run do |qs|
      raise "qs fun fail" unless qs.run(["add_fun", @map])
      @db.by_seq(:startkey => @seq) do |db_seq, doc|
        fun_rows = qs.run(["map_doc", doc.jh])[0]
        fun_rows.each do |r|
          next unless r
          key = r[0]
          value = r[1]
          # puts "insert key #{[key, doc.id].inspect}"
          @index[[key, doc.id]] = value
        end
        @seq = db_seq
      end
    end
  end
  
  def queryParams(p)
    # need to handle false and nil keys properly
    # handle key =
    if p[:key]
      p[:startkey] = p[:key]
      p[:endkey] = p[:key]
      p[:inclusive_end] = "true"
    end
    # handle [key, docid]
    if p[:startkey]
      p[:startkey] = [p[:startkey], p[:startkey_docid]]
    end
    if p[:endkey]
      p[:endkey] = [p[:endkey], (p[:endkey_docid] || {})]
    end
    p
  end
  
  def runQuery(params, &fun)
    rows = []

    @index.fold(queryParams(params)) do |view_key, value|
      # puts "view_key #{view_key.inspect}"
      # puts "value #{value.inspect}"
      
      key = view_key[0]
      id = view_key[1]
      row =  {
        :id => id,
        :key => key,
        :value => value
      }
      if fun
        fun.call(row)
      else
        rows << row
      end
    end
    rows
  end
end

