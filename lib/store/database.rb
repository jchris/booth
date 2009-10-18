require 'tree'
require 'doc'
class Database
  attr_reader :seq
  def initialize
    @by_docid = Tree.new
    @by_seq = Tree.new
    @seq = 0
  end
  def put doc
    doc = Doc.new(doc)
    @seq += 1
    doc.seq = @seq
    @by_seq[@seq] = doc.id
    @by_docid[doc.id] = doc
    doc.id
  end
  def get docid
    @by_docid[docid]
  end
end