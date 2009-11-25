# Booth. In-Memory Ruby CouchDB

Booth is version 0.2. Booth is pre-alpha software right now. The latest milestone reached is support for most Futon database and document operations.

## The Test Suite

Booth is an attempt to get the [CouchDB Test Suite](http://127.0.0.1:5984/_utils/couch_tests.html) to pass against an alternate implementation.

This should hella easy because the CouchDB Test Suite just runs in the browser.

## Protocol

We think the CouchDB runtime can be implemented with varying levels of support.

Level 1 would be a basic key value REST API. This is shared in common with a set of existing tools.

Level 2 includes Map Reduce views.

Level 3 is support for replication with CouchDB instances.

Level 4 is support for CouchDB's JavaScript server runtime environment and APIs.

## Booth

Booth is an implementation of CouchDB in Ruby. It's meant as an illustration of CouchDB as a protocol.

Q: CouchDB uses a robust append only B-Tree implementation for storage, what does Booth use for persistence?
A: Nothing. Booth stores data in Ruby hashes and arrays.

Q: Does it scale?
A: Who the fuck cares?

Q: How can I help?
A: Start shouting about Booth on Twitter and I'll probably notice.

Q: Why "Booth"?
A: It's named after [Special Agent Seeley Booth](http://en.wikipedia.org/wiki/Seeley_Booth) from Bones.

## Get Started

Install the following gems, if you haven't:

    gem install json
    gem install sinatra
    gem install uuid
    gem install cgi

Booth is just a Sinatra server, so to start it, run:

    ruby lib/booth.rb

Visit your Booth Futon's test suite page: [http://127.0.0.1:4567/_utils/couch_tests.html](http://127.0.0.1:4567/_utils/couch_tests.html)

Or just play around in [Futon](http://127.0.0.1:4567/_utils/).

## Patches Very Welcome

Fork. Pick a test, get to green. If you know CouchDB a little, you should be able to tell from it which tests will be easy to fix based on the ones that run.

Some tests require commenting out -- there are certain features (for instance: keeping old revs around) that Booth doesn't bother with, as it is an in-memory store.

Also -- incremental improvements help a lot. Even getting one more assertion to pass is a patch I'll merge.

There is a Ruby RSpec suite you can run like this:

    spec spec/

But I prefer to run it with autospec

    sudo gem install ZenTest
    autospec

### Which Patches?

Replication is not implemented yet. It'll be cool when it is b/c the replicator will work with both Booth and CouchDB endpoints. (You can even replicate between 2 real Couches with the Booth replicator.)

Show and List are almost hooked up. They need the httpd portion - the query server can basically do the work already.

Temp views work but Design Doc views aren't implemented yet, although the groundwork is laid. This would be an ambitious patch but not too invasive, if you are feeling like a hackathon.

Also we need a way to echo chunks to the client instead of buffering. Maybe drop to raw Rack.



