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
    validate_keys!
  end
  
  def id
    self["_id"]
  end
  
  def rev
    self["_rev"]
  end
  
  def deleted
    self["_deleted"]
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
  def validate_keys!
    special_keys = %w{_id _rev _deleted}
    self.each do |k,v|
      if k[0] == "_"
        raise BoothError.new(500, "doc_validation", "bad special field '#{k}'") unless special_keys.include?(k)
      end
    end
  end
end
