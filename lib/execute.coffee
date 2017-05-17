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

  serialize: ->
    runCommandViewState: @runCommandView.serialize()
