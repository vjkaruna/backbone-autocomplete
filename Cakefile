fs = require 'fs'
sysPath = require 'path'
{print} = require 'sys'
{spawn} = require 'child_process'

task 'watch', 'Watch src/ for changes', ->
  coffee = spawn 'coffee', ['-b', '-w', '-c', '-o', 'lib', 'src']
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  coffee.stdout.on 'data', (data) ->
    print data.toString()
