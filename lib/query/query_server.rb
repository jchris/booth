# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.

require 'json'

class QueryServer
  Command = "couchjs #{JS_SERVER_PATH}" 
  def self.run(trace = false)
    puts "launching #{Command}" if trace
    if block_given?
      
      IO.popen(Command, "r+") do |io|
        qs = QueryServer.new(io, trace)
        yield qs
        qs.close
      end
    else
      io = IO.popen(Command, "r+")
      QueryServer.new(io, trace)
    end
  end
  def initialize io, trace = false
    @qsio = io
    @trace = trace
  end
  def close
    @qsio.close
  end
  def reset!
    run(["reset"])
  end
  def add_fun(fun)
    run(["add_fun", fun])
  end
  def get_chunks
    resp = jsgets
    raise "not a chunk" unless resp.first == "chunks"
    return resp[1]
  end
  def run json
    rrun json
    jsgets
  end
  def rrun json
    line = json.to_json
    puts "run: #{line}" if @trace
    @qsio.puts line
  end
  def rgets
    resp = @qsio.gets
    puts "got: #{resp}"  if @trace
    resp
  end
  def jsgets
    resp = rgets
    # err = @qserr.gets
    # puts "err: #{err}" if err
    if resp
      begin
        rj = JSON.parse("[#{resp.chomp}]")[0]
      rescue JSON::ParserError
        puts "JSON ERROR (dump under trace mode)"
        # puts resp.chomp
        while resp = rgets
          # puts resp.chomp
        end
      end
      if rj.respond_to?(:[]) && rj.is_a?(Array)
        if rj[0] == "log"
          log = rj[1]
          puts "log: #{log}" if @trace
          rj = jsgets
        end
      end
      rj
    else
      raise "no response"
    end
  end
end
