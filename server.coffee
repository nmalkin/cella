connect = require 'connect'

api = require './housing_api.js'

server = connect.createServer()
server.use connect.favicon()
server.use connect.logger()
server.use connect.static __dirname + '/public'
server.use connect.router (app) ->
    app.get '/get_rooms', api.get_rooms
    app.get '/room_info', api.room_info
    app.get '/buildings', api.buildings
    app.get '/campus_areas', api.campus_areas


server.listen(8888)
