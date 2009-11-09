class Tree

  attr_accessor :left
  attr_accessor :right
  attr_accessor :key
  attr_accessor :value

  class PassedEnd < StandardError
  end

  def initialize(k=nil, v=nil, &less)
    @trace = true
    trace "new k #{k.inspect}"
    @left = nil
    @right = nil
    @key = k
    @value = v
    @less = less || lambda do |a,b|
      a < b
    end
  end

  def trace m
    puts m if @trace
  end

  def []= k, v
    insert(k, v)
  end
  
  def [] k
    n = search(k)
    n && n.value
  end

  def fold opts={}, &b
    # need to handle false and nil keys properly
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
    desc = opts["descending"] || false
    inc_end = (opts["inclusive_end"] != "false")
    trace "sk #{sk.inspect}"
    trace "ek #{ek.inspect}"
    trace "inc_end #{inc_end.inspect}"
    if (desc)
      foldr(sk, ek, inc_end, &b)
    else
      foldl(sk, ek, inc_end, &b)
    end
  rescue PassedEnd
  end
  
  def foldl sk, ek, inc_end, &b
    trace "foldl preorder @key #{@key.inspect}"
    @left.foldl(sk, ek, inc_end, &b) if @left != nil && ((sk == :none) || !@less.call(@key, sk))
    trace "foldl inorder @key #{@key.inspect}"
    if (ek != :none) 
      if inc_end
        # return if ek < key
        lt = @less.call(ek, @key) #|| !@less.call(@key, ek)
        trace "inc_end lt #{lt} ek #{ek} @key #{@key}"
        raise PassedEnd if lt
      else
        # return if ek <= key
        #   !(ek > @key)
        lte = !@less.call(@key, ek)
        trace "exc_end lte #{lte.inspect} ek #{ek.inspect} @key #{@key.inspect}"
        raise PassedEnd if lte
      end
    end
    if (sk == :none) || !@less.call(@key, sk)
      trace "foldl yield @key #{@key.inspect}"
      b.call(@key, @value)
    end
    trace "foldl prepostorder @key #{@key.inspect}"
    @right.foldl(sk, ek, inc_end, &b) if @right != nil && 
      ((sk == :none) || !@less.call(@right.key, sk))
    trace "foldl postorder @key #{@key.inspect}"
  end
  
  def foldr sk, ek, inc_end, &b
    @right.foldr(sk, ek, inc_end, &b) if @right != nil
    return if (ek != :none) && @less.call(ek, @key)
    b.call(@key, @value) if (sk == :none) || !@less.call(@key, sk)
    @left.foldr(sk, ek, inc_end, &b) if @left != nil && 
      ((sk == :none) || !@less.call(@left.key, sk))
  end
  
  def to_s
     "[" +
     if left then left.to_s + "," else "" end +
     key.inspect +
     if right then "," + right.to_s else "" end + "]"
  end
  
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
  
  
  def inorder()
   @left.inorder {|y| yield y} if @left != nil
   yield @key, @value
   @right.inorder {|y| yield y} if @right != nil
  end
  # 
  # def preorder()
  #  yield @key, @value
  #  @left.preorder {|y| yield y} if @left != nil
  #  @right.preorder {|y| yield y} if @right != nil
  # end
  # 
  # def postorder()
  #  @left.postorder {|y| yield y} if @left != nil
  #  @right.postorder {|y| yield y} if @right != nil
  #  yield @key, @value
  # end
  # 


  # def traverse()
  #   list = []
  #   yield @key, @value
  #   list << @left if @left != nil
  #   list << @right if @right != nil
  #   loop do
  #     break if list.empty?
  #     node = list.shift
  #     yield node.key, node.value
  #     list << node.left if node.left != nil
  #     list << node.right if node.right != nil
  #   end
  # end

end
