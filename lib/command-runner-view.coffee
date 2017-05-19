{$, View} = require 'atom-space-pen-views'
{CommandRunner} = require './command-runner'

Utils = require './utils'

module.exports =
class CommandRunnerView extends View
  @content: ->
    @div class: 'inset-panel panel-bottom execute native-key-bindings', tabindex: -1, =>
      @div class: 'panel-heading', =>
        @span 'Command: '
        @span outlet: 'header'
        @span class: 'execute-close-icon', outlet: 'closeIcon'
      @div class: 'panel-body padded results execute-results-panel', outlet: 'resultsContainer', =>
        @pre class: 'execute-results', outlet: 'results'
      @div class: 'execute-resize-handle', outlet: 'resizeHandle'

  initialize: ->
    @handleEvents()

  handleEvents: ->
    @on 'mousedown', '.execute-resize-handle', (e) => @resizeStarted(e)
    $(@closeIcon).on('click', (e) => @hidePanel())

  resizeStarted: (e) =>
    $(document).on('mousemove', @resizeCommandRunnerView)
    $(document).on('mouseup', @resizeStopped)
    e.preventDefault()

  resizeStopped: (e) =>
    $(document).off('mousemove', @resizeCommandRunnerView)
    $(document).off('mouseup', @resizeStopped)
    e.preventDefault()

  resizeCommandRunnerView: ({pageY, which}) =>
    return @resizeStopped() unless which is 1
    height = @outerHeight() + @offset().top - pageY
    $('.execute-results-panel').height(height)
    $('.execute-results').css({'padding-bottom': '50px'});
    @height(height)

  destroy: ->
    delete @commandRunner
    @detach()

  render: (command, results) =>
    atBottom = @resultsContainer[0].scrollHeight <=
      @resultsContainer[0].scrollTop + @resultsContainer.outerHeight()

    @header.text(command)

    results = Utils.colorize(results)
    @results.html(results)
    @output = results

    if atom.config.get 'execute.snapCommandResultsToBottom'
      @resultsContainer.scrollToBottom()

  hidePanel: =>
    @bottomPane?.hide()
    atom.views.getView(atom.workspace).focus()

  showPanel: =>
    @bottomPane ?= atom.workspace.addBottomPanel(item: this)
    @bottomPane.show()

  togglePanel: ->
    if @bottomPane?.isVisible()
      @hidePanel()
    else
      @bottomPane?.show()

  runCommand: (command, cwd)->
    if @commandRunner?
      @commandRunner.kill()
      delete @commandRunner

    @commandRunner = new CommandRunner(command, cwd, @render)
    @commandRunner.runCommand()
    if !atom.config.get("execute.backgroundCommand")
      @showPanel()

  reRunCommand: (e) =>
    if @commandRunner?
      @commandRunner.kill()

      @commandRunner.runCommand()
      if !atom.config.get("execute.backgroundCommand")
        @showPanel()
    else


  killCommand: (e) =>
    if @commandRunner?
      @commandRunner.kill()
