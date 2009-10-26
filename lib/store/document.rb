require 'base64'
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
    if jrev
      self["_rev"] = jrev
    else
      pick_new_rev!
    end
    validate_keys!
    process_attachments!
  end
  
  def pick_new_rev!
    self["_rev"] = rev_string()
  end
  
  def id
    self["_id"]
  end
  
  def rev
    self["_rev"]
  end
  def etag
    "\"#{self["_rev"]}\""
  end
  def deleted
    self["_deleted"]
  end
  
  def attachment(name)
    if @attachments[name]
      @attachments[name]
    else
      raise BoothError.new(412, "not_found", "missing attachment: '#{name}'");
    end
  end
  
  def attachment_put name, att
    @attachments[name] = att
  end
  
  private
  
  def process_attachments!
    @attachments ||= {}
    if self["_attachments"] 
      self["_attachments"].each do |name, value|
        @attachments[name] = process_attachment(@attachments[name], value)
      end
    end    
  end
  
  def process_attachment(old_att, new_att)
    if new_att["data"]
      data = Base64.decode64(new_att["data"])
    elsif old_att && old_att["data"]
      data = old_att["data"]
    end
    new_att["data"] = data
    new_att
  end
  
  
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
    special_keys = %w{_id _rev _deleted _attachments}
    self.each do |k,v|
      if k[0] == "_"
        raise BoothError.new(500, "doc_validation", "bad special field '#{k}'") unless special_keys.include?(k)
      end
    end
  end
end
