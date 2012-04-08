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


# Use socket.io to broadcast changes in availability information
io = require('socket.io').listen server

# Keep a list of clients while they are connected
clients = []
io.sockets.on 'connection', (socket) ->
    clients.push socket

    # Remove client on disconnect
    socket.on 'disconnect', () ->
        i = clients.indexOf socket
        if i != -1
            clients.splice i, 1

# Connect to Redis
if process.env.REDISTOGO_URL # for production (on Heroku)
    redis = require('redis-url').connect process.env.REDISTOGO_URL
else # Redis running on localhost
    redis = require('redis').createClient()
redis.on 'error', (err) ->
    console.log err

# Use Redis to listen for availability-change events
CHANNEL_TAKEN = 'taken'
redis.on 'message', (channel, message) ->
    room = parseInt message
    console.log "Room #{ room } has been taken."

    # Tell all client about this
    for client in clients
        console.log "Telling client #{ client.id } that #{ room } is taken"
        client.emit 'taken', room

redis.subscribe CHANNEL_TAKEN

# Start collecting availability data
require './availability/scrape.js'
