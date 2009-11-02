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
    @by_seq.fold(opts) do |seq, info|
      if (info)
        b.call(seq, get_doc(info[:id], info[:rev]))
      end
    end
  end
  def all_docs opts={}, &b
    @by_docid.fold(opts) do |docid, doc|
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
  
  def put jdoc, params = {}
    doc = get_doc(jdoc["_id"])
    if doc
      puts "stored doc.rev #{doc.rev}"
      r = doc.update(jdoc, params)
      if r[:old_seq]
        @by_seq[r[:old_seq]] = nil
      end
      @seq += 1
      doc.seq = @seq
      @by_seq[@seq] = r[:info]
    else
      doc = Document.new(self, jdoc)
      @seq += 1
      @doc_count += 1
      doc.seq = @seq
      @by_docid[doc.id] = doc
      @by_seq[@seq] = {:id => doc.id, :rev => doc.rev}
    end
  end
  
  # def putx doc, bulk = false, params = {}
  #   doc = Document.new(self, doc)
  #   if old_doc = get_doc(doc.id)
  #     if old_doc.deleted || doc.rev == old_doc.rev
  #       put_doc doc, old_doc
  #     else
  #       if bulk
  #         if params[:all_or_nothing] == "true"
  #           # write a conflict
  #           put_doc doc, old_doc, :conflict
  #         else
  #           # skip conflicts
  #           {
  #             "id" => doc.id,
  #             "error" => "conflict"              
  #           }
  #         end
  #       else
  #         raise BoothError.new(409, "conflict", "rev mismatch, need '#{old_doc.rev}' for docid '#{doc.id}'");
  #       end
  #     end
  #   else
  #     put_doc doc, nil
  #   end
  # end

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

  def get_doc docid, params={}
    @by_docid[docid]
  end
end