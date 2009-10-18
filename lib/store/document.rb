class Document < Hash
  
  attr_accessor :seq
  def initialize(c = {})
    if c.is_a?(Hash)
      jrev = c.delete("_rev")
      super()
      update(c)
    else
      super(c)
    end
    self["_rev"] = if jrev
      jrev
    else
      rev_string()
    end
    
  end
  
  def id
    self["_id"]
  end
  
  def rev
    self["_rev"]
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
