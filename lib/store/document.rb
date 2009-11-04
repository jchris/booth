require 'base64'
class Document
  
  attr_accessor :seq
  attr_reader :id
  attr_reader :rev
  attr_reader :deleted
  attr_reader :body
  attr_reader :conflicts

  # called only once when the key is allocated
  # could be with a rev (replication) or w/o (put)
  # requires an _id
  def initialize(jdoc)
    @id = jdoc["_id"]
    raise "Document requires an _id" unless @id
    @conflicts = []
    update(jdoc)
  end
    
  def jh(params={})
    if params[:rev] && params[:rev] != @rev
      find_rev(params[:rev]).jh(params)
    else
      doc = {}
      doc["_rev"] = @rev
      doc["_id"] = @id
      if params[:attachments] == "true"
        doc["_attachments"] = inline_attachments 
      elsif @attachments
        doc["_attachments"] = attachment_stubs
      end
      if params[:conflicts] == "true"
        doc["_conflicts"] = conflict_revs
      end
      @body.merge(doc)
    end
  end
  
  def update jdoc, params={}
    # check id
    if !jdoc["_id"] || (jdoc["_id"] != @id)
      raise BoothError.new(400, "bad_request", "id mismatch, doc._id must match #{@id}")
    end
    
    # check rev
    if @rev && jdoc["_rev"] != @rev
      if params[:all_or_nothing] == "true"
        return write_conflict(jdoc)
      else
        raise BoothError.new(409, "conflict", "rev mismatch, need '#{@rev}' for docid '#{@id}'", {:id => @id});
      end
    end
    validate_keys(jdoc)
    
    @rev = @rev ? new_rev() : (jdoc["_rev"] || new_rev())
    @deleted = true if jdoc["_deleted"]
    @body = jdoc
    process_attachments!
    r = {
      :info => {
        :id => @id,
        :rev => @rev
      }
    }
    r[:old_seq] = @seq if @seq
    # callback the db for the seq?
    r
  end
  
  def etag
    "\"#{@rev}\""
  end
  
  def conflicts
    []
  end
  
  def attachment(name)
    if @attachments[name]
      @attachments[name]
    else
      raise BoothError.new(404, "not_found", "missing attachment: '#{name}'");
    end
  end
  
  def attachment_put user_rev, name, att
    if self.rev != user_rev
      raise BoothError.new(409, "conflict", "attachment rev mismatch, need '#{self.rev}' for docid '#{self.id}'");
    end
    validate_att_name(name)
    if att.nil?
      @attachments.delete(name)
    else
      @attachments[name] = att
    end
    @rev = new_rev()
  end

  
  private
  
  # provide a list of the revs of the current heads
  def conflict_revs
    @conflicts.collect{|c|c.rev}
  end
  
  def inline_attachments
    at = {}
    @attachments.each do |name, value|
      at[name] = {
        "data" => Base64.encode64(value["data"]),
        "length" => value["length"],
        "content_type" => value["content_type"]
      }
    end
    at
  end
  
  def attachment_stubs 
    at = {}
    @attachments.each do |name, value|
      at[name] = {
        "length" => value["length"],
        "content_type" => value["content_type"]
      }
    end
    at
  end
  
  def process_attachments!
    @attachments ||= {}
    if @body["_attachments"] 
      @body["_attachments"].each do |name, value|
        validate_att_name(name)
        @attachments[name] = process_attachment(@attachments[name], value)
      end
    end
    @body.delete("_attachments")
  end
  
  def process_attachment(old_att, new_att)
    if new_att["data"]
      data = Base64.decode64(new_att["data"])
    elsif old_att && old_att["data"]
      data = old_att["data"]
    end
    new_att["data"] = data
    new_att["length"] = data.length
    new_att
  end
  
  def validate_att_name(name)
    validate_unicode(name)
    if (name[0] == "_")
      raise BoothError.new(400, 'bad_request', "Attachment name can't start with '_'")
    end
  end
  
  def validate_unicode str, msg = "Invalid unicode"
    begin
      str.unpack 'U*'
    rescue ArgumentError
      raise BoothError.new(400, 'bad_request', msg)
    end
  end
  
  def new_rev
    uuid()
  end
  def uuid
    BOOTH_UUID.generate
  end
  def validate_keys jdoc
    special_keys = %w{_id _rev _deleted _attachments}
    jdoc.each do |k,v|
      if k[0] == "_"
        raise BoothError.new(500, "doc_validation", "bad special field '#{k}'") unless special_keys.include?(k)
      end
    end
  end
  
  def write_conflict(jdoc)
    # first attempt to update an existing confict?
    # just create a new conflict
    doc = Document.new(jdoc)
    @conflicts << doc
    {:info => {:id => doc.id, :rev => doc.rev}}
  end
  
  def find_rev r
    @conflicts.find{|c|c.rev == r}
  end
  
end
