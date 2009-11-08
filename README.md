# Booth. CouchDB, swimming a Ruby soup.

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

and then visit:

    http://localhost:4567/_utils/couch_tests.html

and run the tests.

## Contribute

Fork. Pick a test, get to green. If you know CouchDB a little, you should be able to tell from it which tests will be easy to fix based on the ones that run.

Some tests require commenting out -- there are certain features (for instance: keeping old revs around) that Booth doesn't bother with, as it is an in-memory store.

Also -- incremental improvements help a lot. Even getting one more assertion to pass is a patch I'll merge.

There is a Ruby RSpec suite you can run like this:

    spec spec/

But I prefer to run it with autospec

    sudo gem install ZenTest
    autospec

