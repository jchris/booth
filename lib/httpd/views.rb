require 'view'

post "/:db/_temp_view/?" do
  with_db(params[:db]) do |db|
    req = JSON.parse(request.body.read)
    v = View.new(db, req["map"], req["reduce"])
    j(200, v.query(view_params(params)))
  end
end

def view_params p
  [:startkey, :endkey, :key].each do |k|
    p[k] = fromJSON(p[k]) if p[k]
  end
  p
end

def fromJSON(v)
  JSON.parse("[#{v}]")[0]
end

def buildView(db, map, red)
  map_view = []
  QueryServer.run(:trace) do |qs|
    raise "qs fun fail" unless qs.run(["add_fun", map])
    db.by_seq(:startkey => 0) do |seq, doc|
      # puts "map"
      # puts doc.inspect
      fun_rows = qs.run(["map_doc", doc.jh])[0]
      fun_rows.each do |r|
        next unless r
        key = r[0]
        value = r[1]
        # puts "row #{r.inspect}"
        map_view.push({:key => key, :value => value, :id => doc.id})
      end
    end
    # puts "red #{red.inspect}"
    if red
      # puts "red!"
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

