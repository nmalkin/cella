Cella
=====

Cella is a web-based application to help participants in the Brown University
[Housing Lottery](http://reslife.brown.edu/current_students/lottery/about.html)
identify desired rooms conveniently and efficiently.

It is a successor to _Domus_, a desktop application with similar goals, built by Miya Schneider, Sumner Warren, and me for [CS 32](http://cs.brown.edu/courses/csci0320.html).


Dependencies
------------

This application runs on top of [node.js](http://nodejs.org/) (tested with version 0.6.6).

You will need the following node modules.
They can be most easily obtained using [npm](http://npmjs.org/).

- [CoffeeScript](http://jashkenas.github.com/coffee-script/) (tested with 1.2.0)
- [connect](http://senchalabs.github.com/connect/) (tested with 1.8.5)
- [sqlite3](https://github.com/developmentseed/node-sqlite3) (tested with 2.1.1)


Building
--------
To build the source code for this project, run `cake build` from the top-level directory.

If you are working with the source code, you can use the `--watch / -w` option
so that the project is automatically rebuilt when any of the source files change.

    cake -w build


Running
-------
To run the server:

    node build/server.js

The server runs, by default, on port 8888.
(i.e., to access it, go to `http://127.0.0.1:8888/`)
