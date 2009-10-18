class Doc < Hash
  attr_accessor :seq
  def initialize(constructor = {})
    if constructor.is_a?(Hash)
      super()
      update(constructor)
    else
      super(constructor)
    end
  end
  
  def id
    self["_id"]
  end
  
  private
  def update(other_hash)
    other_hash.each_pair do |key, value|
      self[key] = value
    end
    self
  end

end
