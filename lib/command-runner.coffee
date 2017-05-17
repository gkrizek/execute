{BufferedProcess} = require 'atom'
Utils = require './utils'

class CommandRunner
  processor: BufferedProcess
  commandResult: ''

  constructor: (command, cwd, callback)->
    @command = command
    @cwd = cwd
    @callback = callback

  collectResults: (output) =>
    # Found out that html objects still get renderend and they shouldn't, perform htmlEncode
    @commandResult += output.toString().replace(/&/g, '&amp;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
    @returnCallback()

  exit: (code) =>
    @returnCallback()

  processParams: ->
    isWin = /^win/.test(process.platform)
    if (!isWin)
      command: if atom.config.get("execute.shellCommand")? then atom.config.get("execute.shellCommand") else '/bin/bash'
      args: ['-c', @addPrecedentCommand(@command), '-il']
      options:
        cwd: @cwd
      exit: @exit
    else
      input = Utils.clean(@command.split(/(\s+)/))
      command: input[0]
      args: input.slice(1)
      options:
        cwd: @cwd
      exit: @exit

  returnCallback: =>
    @callback(@command, @commandResult)

  runCommand: ->
    @commandResult = ''
    @process = new @processor @processParams()

    @process.process.stdout.on 'data', @collectResults
    @process.process.stderr.on 'data', @collectResults

  kill: ->
    if @process?
      @process.kill()

  addPrecedentCommand: (command)=>
    precedent = atom.config.get 'execute.precedeCommandsWith'

    if precedent? and !Utils.stringIsBlank(precedent)
      @joinCommands [precedent, command]
    else
      command

  joinCommands: (commands)=>
    commands.join(' && ')

module.exports =
  CommandRunner: CommandRunner
