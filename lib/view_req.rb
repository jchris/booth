
post "/:db/_temp_view/?" do
  with_db(params[:db]) do |db|
    req = JSON.parse(request.body.read)
    view = buildView(db, req["map"], req["reduce"])
    j(200, view)
  end
end

def buildView(db, map, red)
  mapper = OSProcess.new()
  mapper.learn_map(map)
  db.each do |id, doc|
    puts doc.inspect

  end
end

