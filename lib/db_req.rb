# json error
def je code, name, message
  status code
  {"error" => name, "reason" => message}.to_json
end

def j code, json
  status code
  json.to_json
end

put "/:db/" do
  db = params[:db]
  if Booth[db]
    je(412, "db_exists", "The database already exists.")
  else
    Booth[db] = {}
    headers "Location" => "/#{CGI.escape(db)}"
    j(201, {"ok" => true})
  end
end

get "/:db/" do
  db = params[:db]
  if Booth[db]
    j(200, {
      :db_name => db,
      :doc_count => db.length
    })
  else
    Booth[db] = {}
    headers "Location" => "/#{CGI.escape(db)}"
    je(404, "not_found", "No database: #{db}")
  end
end


delete "/:db/" do
  db = params[:db]
  if Booth[db]
    Booth.delete(db)
    j(200, {"ok" => true})
  else
    je(404, "not_found", "No database: #{db}")
  end
end