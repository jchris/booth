class Tree

  attr_accessor :left
  attr_accessor :right
  attr_accessor :key
  attr_accessor :value

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
    sk = opts[:startkey] || :none
    ek = opts[:endkey] || :none
    desc = opts[:descending] || false
    trace "sk #{sk.inspect}"
    trace "ek #{ek.inspect}"
    if (desc)
      foldr(sk, ek, &b)
    else
      foldl(sk, ek, &b)
    end
  end
  
  def foldl sk=:none, ek=:none, &b
    trace "foldl preorder @key #{@key.inspect}"
    @left.foldl(sk, ek, &b) if @left != nil
    trace "foldl inorder @key #{@key.inspect}"
    return if (ek != :none) && @less.call(ek, @key)
    trace "foldl yield @key #{@key.inspect}"
    b.call(@key, @value) if (sk == :none) || !@less.call(@key, sk)
    trace "foldl prepostorder @key #{@key.inspect}"
    @right.foldl(sk, ek, &b) if @right != nil && 
      ((sk == :none) || !@less.call(@right.key, sk))
    trace "foldl postorder @key #{@key.inspect}"
  end
  
  def foldr sk=nil, ek=nil, &b
    @right.foldr(sk, ek, &b) if @right != nil
    return if (ek != :none) && @less.call(ek, @key)
    b.call(@key, @value) if (sk == :none) || !@less.call(@key, sk)
    @left.foldr(sk, ek, &b) if @left != nil && 
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
