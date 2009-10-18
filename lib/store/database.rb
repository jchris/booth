require 'tree'
require 'document'
class Database
  attr_reader :seq
  attr_reader :doc_count
  def initialize
    @by_docid = Tree.new
    @by_seq = Tree.new
    @seq = 0
    @doc_count = 0
  end
  def by_seq opts, &b
    @by_seq.fold(opts) do |seq, docid|
      if (docid)
        b.call(seq, @by_docid[docid])
      end
    end
  end
  def each opts, &b
    
  end
  def []= docid, doc
    doc["_id"] ||= docid
    raise "invalid id" if doc["_id"] != docid
    put doc
  end
  def [] docid
    get docid
  end
  def delete doc
    {
      "_id" => doc["_id"],
      "_rev" => doc["_rev"],
      "_deleted" => true
    }
    put doc
  end
  def put doc
    doc = Document.new(doc)
    if old_doc = @by_docid[doc.id]
      if doc.rev == old_doc.rev
        put_doc doc, old_doc
      else
        raise "rev conflict"
      end
    else
      put_doc doc
    end
  end
  def get docid
    @by_docid[docid]
  end
  private
  def put_doc doc, old=nil
    # clear old seq
    if old
      @by_seq[old.seq] = nil
    else
      @doc_count += 1
    end
    @seq += 1
    doc.seq = @seq
    @by_seq[@seq] = doc.id
    @by_docid[doc.id] = doc
    doc.rev
  end
end