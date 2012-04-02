connect = require 'connect'

# Support for server-wide events
exports.events = new (require 'events').EventEmitter

# Set up API and server
api = require './api'

server = connect.createServer()
server.use connect.favicon __dirname + '/..' + '/public/favicon.ico'
server.use connect.logger()
server.use connect.router (app) ->
    app.get '/get_rooms', api.get_rooms
    app.get '/room_info', api.room_info
    app.get '/buildings', api.buildings
    app.get '/campus_areas', api.campus_areas
    app.get '/results', api.results
    app.get '/floorplan', api.floorplan
    app.get '/availability', api.availability
server.use connect.static __dirname + '/..' + '/public'

server.listen(8888)


# Start collecting availability data
require './availability/scrape.js'
