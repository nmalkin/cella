{exec} = require 'child_process'

frontendFiles = [
    'debug'
    'constants'
    'globals'
    'persistence'
    'roomdisplay'
    'probability'
    'filters'
    'roomprocessing'
    'star'
    'tabs'
    'events'
    'startup'
]

task 'build:frontend', 'Build frontend code', ->
    files = ("src/frontend/#{ file }.coffee" for file in frontendFiles).join ' '
    exec "coffee --compile --join index.coffee --output public/scripts/ #{ files }",
        (err, stdout, stderr) ->
            throw err if err
            if stdout or stderr
                console.log stdout + stderr

task 'build:server', 'Build server code', ->
    exec 'coffee --compile --output build/ src/server/',
        (err, stdout, stderr) ->
            throw err if err
            if stdout or stderr
                console.log stdout + stderr


task 'build', 'Build project', ->
    invoke 'build:server'
    invoke 'build:frontend'
