require 'tree'
require 'doc'
class Database
  attr_reader :seq
  def initialize
    @by_docid = Tree.new
    @by_seq = Tree.new
    @seq = 0
  end
  def by_seq opts, &b
    @by_seq.fold(opts) do |seq, docid|
      if (docid)
        b.call(docid, @by_docid[docid])
      end
    end
  end
  def put doc
    doc = Doc.new(doc)
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
    end
    @seq += 1
    doc.seq = @seq
    @by_seq[@seq] = doc.id
    @by_docid[doc.id] = doc
    doc.id
  end
end