class Booth
  class Fail
    def initialize name, message
      
    end
  end
  @@dbs = {}
  def create_db name, db
    raise Fail(412, "db_exists", "The database already exists.") if @@dbs[name]
  @@dbs[name] = db
  {"created" => name}
  end
  # def get_db name
  #   @@dbs[name]
  # end
end