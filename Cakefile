fs = require 'fs'
sysPath = require 'path'
{print} = require 'sys'
{spawn} = require 'child_process'

ex = (module, params) ->
  coffee = spawn module, params
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  coffee.stdout.on 'data', (data) ->
    print data.toString()

task 'build', 'Build .js file from source .coffee', ->
  ex 'coffee', ['-o', './', '-c', 'src/autocomplete.coffee']
  ex 'coffee', ['-b', '-o', './examples/lib', '-c', 'src/autocomplete.coffee']

task 'docs', 'Generate docs', ->
  ex 'docco', ['-o', 'docs/', 'src/autocomplete.coffee']

task 'watch', 'Watch src/ for changes', ->
  ex 'coffee', ['-b', '-w', '-c', '-o', 'lib', 'src']
