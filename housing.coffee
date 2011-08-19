sqlite = require 'sqlite3'
sqlite = sqlite.verbose() # for easier debugging

exports.db = new sqlite.Database __dirname + '/housingdata.sqlite'

process.on 'exit', ->
    exports.db.close()
