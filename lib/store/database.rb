require 'tree'
require 'doc'
class Database
  def initialize
    @by_docid = Tree.new
  end
  def put doc
    doc = Doc.new(doc)
    @by_docid[doc.id] = doc
  end
  def get docid
    @by_docid[docid]
  end
end