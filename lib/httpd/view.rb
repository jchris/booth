require 'query_server'

post "/:db/_temp_view/?" do
  with_db(params[:db]) do |db|
    req = JSON.parse(request.body.read)
    view = buildView(db, req["map"], req["reduce"])
    j(200, view)
  end
end

def buildView(db, map, red)
  map_view = []
  QueryServer.run(:trace) do |qs|
    raise "qs fun fail" unless qs.run(["add_fun", map])
    db.each do |id, doc|
      puts "map"
      puts doc.inspect
      fun_rows = qs.run(["map_doc", doc])[0]
      fun_rows.each do |r|
        next unless r
        key = r[0]
        value = r[1]
        puts "row #{r.inspect}"
        map_view.push({:key => key, :value => value, :id => id})
      end
    end
    puts "red #{red.inspect}"
    if red
      puts "red!"
      qs.reset!
      kvs = []
      map_view.each do |row|
        kvs << [row[:key], row[:value]]
      end
      resp = qs.run(["reduce", [red], kvs])
      # raise "reduce fail" unless resp[0] == true
      return {
        :rows => [{:value => resp[1]}],
        "foo" => "bar"
      }
    else
      return {
        :rows => map_view,
        :total_rows => map_view.length
      }
    end
  end
end

