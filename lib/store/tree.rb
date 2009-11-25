# This is a basic binary tree
# You could build a btree that maintains this API.
# If you did that'd be cool.
class Tree

  attr_accessor :left
  attr_accessor :right
  attr_accessor :key
  attr_accessor :value

  class PassedEnd < StandardError
  end

  def initialize(k=nil, v=nil, &less)
    # set this to true to make it spew debug logging
    @trace = false  
    trace "new k #{k.inspect}"
    @left = nil
    @right = nil
    @key = k
    @value = v
    @less = less || lambda do |a,b|
      a < b
    end
  end
  
  # this is helpful for debugging
  def to_s
     "[" +
     if left then left.to_s + "," else "" end +
     key.inspect +
     if right then "," + right.to_s else "" end + "]"
  end

  # spew traversal logs
  def trace m
    puts m if @trace
  end

  # set a key/value
  def []= k, v
    insert(k, v)
  end
  # get a value by key
  def [] k
    n = search(k)
    n && n.value
  end

  # visit the members of the btree in
  # sorted order. this is the basis of
  # replication and incremental map reduce.
  def fold opts={}, &b
    keys = opts.keys
    if keys.include?("startkey")
      sk = opts["startkey"]
    else 
      sk = :none
    end
    if keys.include?("endkey")
      ek = opts["endkey"]
    else 
      ek = :none
    end
    fwd = opts["descending"] != "true"
    inc_end = (opts["inclusive_end"] != "false")
    trace "sk #{sk.inspect}"
    trace "ek #{ek.inspect}"
    trace "inc_end #{inc_end.inspect}"
    if (!fwd)
      # we switch start and end key
      # when the direction is backwards
      foldint(ek, sk, inc_end, fwd, &b)
    else
      foldint(sk, ek, inc_end, fwd, &b)
    end
  rescue PassedEnd
  end
  
  protected
  
  # this is the internal tree index traversal algorithm.
  # it's probably sub-optimal, but it works.
  def foldint sk, ek, inc_end, fwd, &b
    front = fwd ? @left : @right
    back = fwd ? @right : @left
    trace "fold preorder @key #{@key.inspect}"
    front.foldint(sk, ek, inc_end, fwd, &b) if front && 
      ((sk == :none) || !@less.call(@key, sk))
    trace "fold inorder @key #{@key.inspect}"
    if (ek != :none) 
      if inc_end
        lt = @less.call(ek, @key)
        trace "inc_end lt #{lt} ek #{ek} @key #{@key}"
        raise PassedEnd if lt
      else
        lte = !@less.call(@key, ek)
        trace "exc_end lte #{lte.inspect} ek #{ek.inspect} @key #{@key.inspect}"
        raise PassedEnd if lte
      end
    end
    if (sk == :none) || !@less.call(@key, sk)
      trace "fold yield @key #{@key.inspect}"
      b.call(@key, @value)
    end
    trace "fold prepostorder @key #{@key.inspect}"
    back.foldint(sk, ek, inc_end, fwd, &b) if back
    # if back && ((sk == :none) || !@less.call(back.key, sk))
    trace "fold postorder @key #{@key.inspect}"
  end
  
  # insert a value at a key
  # will replace the old value
  def insert(k, v)
    trace "insert k #{k} @key #{@key}"
    if @key == nil || @key == k
      @key = k
      @value = v
    elsif @less.call(k, @key)
      if @left == nil
        @left = Tree.new k, v, &@less
      else
        @left.insert k, v
      end
    else
      if @right == nil
        @right = Tree.new k, v, &@less
      else
        @right.insert k, v
      end
    end
  end
  
  # return the node for a given key
  def search(k)
    if self.key == k
      return self
    else
      ltree = left != nil ? left.search(k) : nil
      return ltree if ltree != nil
      rtree = right != nil ? right.search(k) : nil
      return rtree if rtree != nil
    end
    nil
  end

end
