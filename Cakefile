{exec} = require 'child_process'

task 'build:server', 'Build server code', ->
    exec 'coffee --compile --output build/ src/server/',
        (err, stdout, stderr) ->
            throw err if err
            console.log stdout + stderr

task 'build:frontend', 'Build frontend code', ->
    exec 'coffee --compile --output public/scripts/ src/frontend/index.coffee',
        (err, stdout, stderr) ->
            throw err if err
            console.log stdout + stderr


task 'build', 'Build project', ->
    invoke 'build:server'
    invoke 'build:frontend'
