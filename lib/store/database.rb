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
  def by_seq opts={}, &b
    @by_seq.fold(opts) do |seq, docid|
      if (docid)
        b.call(seq, get_doc(docid))
      end
    end
  end
  def all_docs opts={}, &b
    @by_docid.fold(opts) do |docid, heads|
      doc = heads[0]
      next if doc.deleted
      b.call(docid, doc)
    end
  end
  def delete docid, rev
    doc = {
      "_id" => docid,
      "_rev" => rev,
      "_deleted" => true
    }
    new_rev = put doc
    @doc_count -= 1
    new_rev
  end
  def put doc, bulk = false, params = {}
    doc = Document.new(self, doc)
    if old_doc = get_doc(doc.id)
      if old_doc.deleted || doc.rev == old_doc.rev
        put_doc doc, old_doc
      else
        if bulk
          if params[:all_or_nothing] == "true"
            # write a conflict
            put_doc doc, old_doc, :conflict
          else
            # skip conflicts
            {
              "id" => doc.id,
              "error" => "conflict"              
            }
          end
        else
          raise BoothError.new(409, "conflict", "rev mismatch, need '#{old_doc.rev}' for docid '#{doc.id}'");
        end
      end
    else
      put_doc doc, nil
    end
  end
  def get docid, params={}
    doc = get_doc(docid, params)
    if !doc
      raise BoothError.new(404, "not_found", "missing doc '#{docid}'");
    elsif doc.deleted
      raise BoothError.new(404, "not_found", "deleted doc '#{docid}'");
    else
      doc
    end
  end
  private
  def put_doc doc, old, conflict=false
    # clear old seq
    if old
      @by_seq[old.seq] = nil unless conflict
    else
      @doc_count += 1
    end
    @seq += 1
    doc.seq = @seq
    @by_seq[@seq] = doc.id
    doc.pick_new_rev!
    puts "saving #{doc.id} with rev #{doc.rev}"
    if conflict
      heads = @by_docid[doc.id]
      heads.push(doc)
      @by_docid[doc.id] = heads      
    else
      @by_docid[doc.id] = [doc]
    end
    {
      "rev" => doc.rev,
      "id" => doc.id
    }
  end
  def get_doc docid, params={}
    heads = @by_docid[docid]
    if heads
      if params[:conflicts] == true
        doc = heads.shift
        doc["_conflicts"] = heads
      else
        heads[0]
      end
    end
  end
end