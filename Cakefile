{exec} = require 'child_process'
task 'build', 'Build CoffeeScript files in project', ->
    exec 'coffee --compile *.coffee public/scripts/index.coffee', (err, stdout, stderr) ->
        throw err if err
        console.log stdout + stderr
