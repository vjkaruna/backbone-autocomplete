fs = require 'fs'
sysPath = require 'path'
{print} = require 'sys'
{spawn} = require 'child_process'

task 'docs', 'Generate docs', ->
  coffee = spawn 'docco', ['-o', 'docs/', 'src/autocomplete.coffee']
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  coffee.stdout.on 'data', (data) ->
    print data.toString()

task 'watch', 'Watch src/ for changes', ->
  coffee = spawn 'coffee', ['-b', '-w', '-c', '-o', 'lib', 'src']
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  coffee.stdout.on 'data', (data) ->
    print data.toString()
