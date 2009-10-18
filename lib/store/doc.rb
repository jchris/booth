class Doc < Hash
  
  attr_accessor :seq
  attr_accessor :revs
  def initialize(c = {})
    if c.is_a?(Hash)
      super()
      update(c)
    else
      super(c)
    end
    if !self.rev
      @revs = [rev_string()]
    end
  end
  
  def id
    self["_id"]
  end
  
  def rev
    @revs && @revs.first
  end
  
  private
  def update(other_hash)
    other_hash.each_pair do |key, value|
      self[key] = value
    end
    self
  end
  def rev_string
    uuid = UUID.new
    uuid.generate
  end
end
