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

### High-level status

The Tree class is getting most of the needed features, but could be self-balancing. Also it still needs analysis about which are public and private methods.

Database and Document are mostly right, but some thought needs to go into a JSON abstraction layer for documents.

The Sinatra parts are pretty self explanatory.

Temp views barely work. They are recalculated at run-time for every query, and don't have start and end keys yet. However, the do use the couchjs/main.js CouchDB JavaScript process, so once they are hooked to proper Trees they should be mostly real.

I'm really trying hard not too get to Ruby-ish with the coding style, so please hold back on "I refactored and everything's a module..." refactors. The purpose of this CouchDB implementation isn't to be perfect, but to be an easy reference for people considering porting CouchDB to other languages.


