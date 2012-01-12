{exec, spawn} = require 'child_process'

option '-w', '--watch', 'Watch source files for changes'

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

processOutput = (err, stdout, stderr) ->
    throw err if err
    if stdout or stderr
        console.log stdout + stderr


task 'build:frontend', 'Build frontend code', ->
    files = ("src/frontend/#{ file }.coffee" for file in frontendFiles).join ' '
    exec "coffee --compile --join index.coffee --output public/scripts/ #{ files }",
        processOutput

task 'build:frontend:watch', 'Rebuild frontend when source changes', ->
    args = ['--compile', '--watch', '--join', 'index.coffee',
        '--output', 'public/scripts/']
    files = ("src/frontend/#{ file }.coffee" for file in frontendFiles)
    spawn 'coffee', (args.concat files), customFds: [0..2]

task 'build:server', 'Build server code', ->
    exec 'coffee --compile --output build/ src/server/',
        processOutput

task 'build:server:watch', 'Rebuild server when source changes', ->
    spawn 'coffee', ['--compile', '--watch', '--output', 'build/', 'src/server/'],
        customFds: [0..2]

task 'build', 'Build project', (options) ->
    if options.watch?
        invoke 'build:frontend:watch'
        invoke 'build:server:watch'
    else
        invoke 'build:server'
        invoke 'build:frontend'
