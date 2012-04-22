Cella
=====
Cella is a web-based application to help participants in the Brown University
[Housing Lottery](http://reslife.brown.edu/current_students/lottery/about.html)
identify desired rooms conveniently and efficiently.

It is a successor to _Domus_, a desktop application with similar goals, built by Miya Schneider, Sumner Warren, and me for [CS 32](http://cs.brown.edu/courses/csci0320.html).


Dependencies
------------
This application runs on top of [node.js](http://nodejs.org/).

Cella depends on the following node modules:

- [iced-coffee-script](http://maxtaco.github.com/coffee-script/)
- [connect](http://senchalabs.github.com/connect/)
- [sqlite3](https://github.com/developmentseed/node-sqlite3)
- [github-flavored-markdown](https://github.com/isaacs/github-flavored-markdown)
- [mustache](https://github.com/janl/mustache.js)
- [less](http://lesscss.org/) (for Bootstrap)
- [uglify-js](https://github.com/mishoo/UglifyJS) (for Bootstrap)
- [redis](https://github.com/mranney/node_redis)
- [redis-url](https://github.com/ddollar/redis-url)
- [socket.io](http://socket.io/)

Cella uses [npm](http://npmjs.org/) to manage these dependencies.  
When you have npm installed, go to Cella's directory and run:

    npm install

Afterwards, you can run `npm update` to make sure you have the latest dependencies installed.

You will also need a running instance of the [Redis database server](http://redis.io/).

Additional dependencies are included as submodules within the Git repository.
To get them, once you have cloned the repository:

    git submodule init
    git submodule update
    ./cake build:dependencies
    ./cake install:dependencies

Note that you will need to build and install the dependencies
whenever any submodules change.


Building
--------
To build the source code for this project, run `./cake build` from the top-level directory.

If you are working with the source code, you can use the `--watch / -w` option
so that the project is automatically rebuilt when any of the source files change.

    ./cake -w build


Running
-------
To run the server:

    npm start

The server runs, by default, on port 8888.
(i.e., to access it, go to http://127.0.0.1:8888/)
