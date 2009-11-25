require 'tree'
require 'document'

# This class represents an in-memory 
# CouchDB database. It is designed to
# support p2p-replication using CouchDB's
# replication protocol.
class Database
  
  attr_reader :seq
  attr_reader :doc_count
  
  def initialize
    @by_docid = Tree.new do |a, b|
      View.less_string(a,b)
    end
    @by_seq = Tree.new
    @seq = 0
    @doc_count = 0
  end
  
  # traverse what's happened since the 
  # last time you asked
  def by_seq opts={}, &b
    @by_seq.fold(opts) do |seq, info|
      if (info)
        b.call(seq, get_doc(info[:id], info[:rev]))
      end
    end
  end
  
  # traverse the all_docs view, by docid
  def all_docs opts={}, &b
    ks = opts.keys
    if ks.include?("key")
      opts["startkey"] = opts["key"]
      opts["endkey"] = opts["key"]
      opts["inclusive_end"] = "true"
    end
    @by_docid.fold(opts) do |docid, doc|
      next if doc.deleted
      b.call(docid, doc)
    end
  end
  
  # update the database, creating a new 
  # doc  or updating and existing one.
  def put jdoc, params = {}
    doc = get_doc(jdoc["_id"])
    if doc
      # puts "stored doc.rev #{doc.rev}"
      r = doc.update(jdoc, params)
      if r[:old_seq]
        @by_seq[r[:old_seq]] = nil
      end
      @seq += 1
      doc.seq = @seq
      @by_seq[@seq] = r[:info]
    else
      doc = Document.new(jdoc)
      @seq += 1
      @doc_count += 1
      doc.seq = @seq
      @by_docid[doc.id] = doc
      @by_seq[@seq] = {:id => doc.id, :rev => doc.rev}
    end
  end

  # get a document by id
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

  # delete a document by id
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
  
  private

  # this used to handle conflicts and stuff 
  # before I pushed that code into document.rb
  def get_doc docid, params={}
    @by_docid[docid]
  end
end