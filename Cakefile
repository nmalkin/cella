COFFEE = 'coffee'

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

libraryFiles = # library location : production location
    # JS
    'lib/chosen/chosen/chosen.jquery.js' : 'public/scripts/chosen.js'
    'lib/bootstrap/js/bootstrap-dropdown.js' : 'public/scripts/bootstrap-dropdown.js'
    'lib/bootstrap/js/bootstrap-tabs.js' : 'public/scripts/bootstrap-tabs.js'
    'lib/tablesorter/js/jquery.tablesorter.js' : 'public/scripts/tablesorter.js'

    # CSS
    'lib/chosen/chosen/chosen.css' : 'public/styles/chosen.css'
    'lib/chosen/chosen/chosen-sprite.png' : 'public/styles/chosen-sprite.png'
    'lib/bootstrap/bootstrap.css' : 'public/styles/bootstrap.css'

processOutput = (err, stdout, stderr) ->
    throw err if err
    if stdout or stderr
        console.log stdout + stderr


option '-c', '--coffee [PATH]', 'Path to CoffeeScript executable'

task 'build:frontend', 'Build frontend code', (options) ->
    coffee = options.coffee ? COFFEE

    files = ("src/frontend/#{ file }.coffee" for file in frontendFiles).join ' '
    exec "#{coffee} --compile --join index.coffee --output public/scripts/ #{ files }",
        processOutput

task 'build:frontend:watch', 'Rebuild frontend when source changes', (options) ->
    coffee = options.coffee ? COFFEE

    args = ['--compile', '--watch', '--join', 'index.coffee',
        '--output', 'public/scripts/']
    files = ("src/frontend/#{ file }.coffee" for file in frontendFiles)
    spawn coffee, (args.concat files), customFds: [0..2]

task 'build:server', 'Build server code', (options) ->
    coffee = options.coffee ? COFFEE

    exec "#{coffee} --compile --output build/ src/server/",
        processOutput

task 'build:server:watch', 'Rebuild server when source changes', (options) ->
    coffee = options.coffee ? COFFEE

    spawn coffee, ['--compile', '--watch', '--output', 'build/', 'src/server/'],
        customFds: [0..2]

option '-w', '--watch', 'Watch source files for changes'
task 'build', 'Build project', (options) ->
    if options.watch?
        invoke 'build:frontend:watch'
        invoke 'build:server:watch'
    else
        invoke 'build:server'
        invoke 'build:frontend'


task 'install:dependencies', 'Install front-end dependencies', ->
    exec "cp -f #{ oldLocation } #{ newLocation }", processOutput \
        for oldLocation, newLocation of libraryFiles

task 'install', 'Install application', ->
    invoke 'install:dependencies'
