RunCommandView = require './execute-view'
CommandRunnerView = require './command-runner-view'

module.exports =
  config:
    shellCommand:
      type: 'string'
      default: '/bin/bash'
    precedeCommandsWith:
      type: 'string'
      default: ''
    snapCommandResultsToBottom:
      type: 'boolean'
      default: true

  runCommandView: null
  commandRunnerView: null
  cwdView: null

  activate: (state) ->
    @commandRunnerView = new CommandRunnerView()
    @runCommandView = new RunCommandView(@commandRunnerView)

  deactivate: ->
    @runCommandView.destroy()
    @commandRunnerView.destroy()
    @cwdView.destroy()
###

{ContentDisposable} = require 'atom'
CommandRunner = require './command-runner'
RunCommandView = require './run-command-view'
CommandOutputView = require './command-output-view'

module.exports =
  config:
    shellCommand:
      type: 'string'
      default: '/bin/bash'
    useLoginShell:
      type: 'boolean'
      default: true

  activate: (state) ->
    @runner = new CommandRunner()

    @commandOutputView = new CommandOutputView(@runner)
    @runCommandView = new RunCommandView(@runner)

    @subscriptions = atom.commands.add 'atom-workspace',
      'run-command:run': => @run()
      'run-command:toggle-panel': => @togglePanel(),
      'run-command:kill-last-command': => @killLastCommand()

  deactivate: ->
    @runCommandView.destroy()
    @commandOutputView.destroy()

  dispose: ->
    @subscriptions.dispose()



  run: ->
    @runCommandView.show()

  togglePanel: ->
    if @commandOutputView.isVisible()
      @commandOutputView.hide()
    else
      @commandOutputView.show()

  killLastCommand: ->
    @runner.kill()
    ###
