class Tree

  attr_accessor :left
  attr_accessor :right
  attr_accessor :key
  attr_accessor :value
  attr_accessor :parent

  def initialize(k=nil, v=nil, p=nil)
    @left = nil
    @right = nil
    @key = k
    @value = v
    @parent = p
  end

  def []= k, v
    insert(k, v)
  end
  
  def [] k
    search(k).value
  end

  def fold opts={}, &b
    sk = opts[:startkey] || nil
    ek = opts[:endkey] || nil
    desc = opts[:descending] || false
    if (desc)
      foldr(sk, ek, &b)
    else
      foldl(sk, ek, &b)
    end
  end
  
  def foldl sk=nil, ek=nil, &b
    @left.foldl(sk, ek, &b) if @left != nil
    return if ek && ek <= @key
    b.call(@key, @value) if !sk || @key >= sk
    @right.foldl(sk, ek, &b) if @right != nil && 
      (!sk || @right.key >= sk)
  end
  
  def to_s
     "[" +
     if left then left.to_s + "," else "" end +
     key.inspect +
     if right then "," + right.to_s else "" end + "]"
  end
  
  def insert(k, v)
   if @key == nil
    @key = k
    @value = v
   elsif k <= @key
    if @left == nil
     @left = Tree.new k, v, self
    else
     @left.insert k, v
    end
   else
    if @right == nil
     @right = Tree.new k, v, self
    else
     @right.insert k, v
    end
   end
  end

  def inorder()
   @left.inorder {|y| yield y} if @left != nil
   yield @key, @value
   @right.inorder {|y| yield y} if @right != nil
  end

  def preorder()
   yield @key, @value
   @left.preorder {|y| yield y} if @left != nil
   @right.preorder {|y| yield y} if @right != nil
  end

  def postorder()
   @left.postorder {|y| yield y} if @left != nil
   @right.postorder {|y| yield y} if @right != nil
   yield @key, @value
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
