connect = require 'connect'

api = require './housing_api.js'

server = connect.createServer()
server.use connect.favicon __dirname + '/..' + '/public/favicon.ico'
server.use connect.logger()
server.use connect.router (app) ->
    app.get '/get_rooms', api.get_rooms
    app.get '/room_info', api.room_info
    app.get '/buildings', api.buildings
    app.get '/campus_areas', api.campus_areas
server.use connect.static __dirname + '/..' + '/public'


server.listen(8888)
