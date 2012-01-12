{exec, spawn} = require 'child_process'

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

task 'install:dependencies', 'Install front-end dependencies', ->
    # JS
    exec 'cp -f lib/chosen/chosen/chosen.jquery.js public/scripts/chosen.js', processOutput
    exec 'cp -f lib/bootstrap/js/bootstrap-dropdown.js public/scripts/bootstrap-dropdown.js', processOutput
    exec 'cp -f lib/bootstrap/js/bootstrap-tabs.js public/scripts/bootstrap-tabs.js', processOutput

    # CSS
    exec 'cp -f lib/chosen/chosen/chosen.css public/styles/chosen.css', processOutput
    exec 'cp -f lib/chosen/chosen/chosen-sprite.png public/styles/chosen-sprite.png', processOutput
    exec 'cp -f lib/bootstrap/bootstrap.css public/styles/bootstrap.css', processOutput

task 'build:frontend', 'Build frontend code', ->
    files = ("src/frontend/#{ file }.coffee" for file in frontendFiles).join ' '
    exec "coffee --compile --join index.coffee --output public/scripts/ #{ files }",
        processOutput

task 'build:watch:frontend', 'Rebuild frontend when source changes', ->
    args = ['--compile', '--watch', '--join', 'index.coffee',
        '--output', 'public/scripts/']
    files = ("src/frontend/#{ file }.coffee" for file in frontendFiles)
    spawn 'coffee', (args.concat files), customFds: [0..2]

task 'build:server', 'Build server code', ->
    exec 'coffee --compile --output build/ src/server/',
        processOutput

task 'build:watch:server', 'Rebuild server when source changes', ->
    spawn 'coffee', ['--compile', '--watch', '--output', 'build/', 'src/server/'],
        customFds: [0..2]

option '-w', '--watch', 'Watch source files for changes'
task 'build', 'Build project', (options) ->
    if options.watch?
        invoke 'build:watch:frontend'
        invoke 'build:watch:server'
    else
        invoke 'build:server'
        invoke 'build:frontend'
