{$, View, TextEditorView} = require 'atom-space-pen-views'
{CommandRunner} = require './command-runner'
{CommandRunnerView} = require './command-runner-view'

{Disposable, CompositeDisposable} = require 'atom'

CWDView = require './cwd-view'
CommandEntry = require './command-entry'
Utils = require './utils'

module.exports =
class RunCommandView extends View

  @content: ->
    @div class: 'inset-panel panel-top execute'

  initialize: (commandRunnerView)->
    @disposables = new CompositeDisposable

    @commandRunnerView = commandRunnerView

    atom.commands.add 'atom-workspace', 'execute:command', =>
      atom.config.set("execute.backgroundCommand", false)
      @toggle()
    atom.commands.add 'atom-workspace', 'execute:background', =>
      atom.config.set("execute.backgroundCommand", true)
      @toggle()
    atom.commands.add 'atom-workspace', 'execute:re-run-last-command', =>
      @reRunCommand()
    atom.commands.add 'atom-workspace', 'execute:toggle-panel', =>
      @togglePanel()
    atom.commands.add 'atom-workspace', 'execute:kill-last-command', =>
      @killLastCommand()
    atom.commands.add 'atom-workspace', 'execute:cwd', =>
      @setWorkingDirectory()
    atom.commands.add 'atom-workspace', 'execute:copy', =>
      @copyBuffer()

    @disposables.add atom.commands.add @element,
      'core:confirm': =>
        @runCommand()
      'core:cancel': =>
        @hide()

  setWorkingDirectory: =>

    if not @cwd?
      @cwd ?= new CWDView()
    else
      @toggleCWD()

  toggle: =>
    if not @entry?
      @entry ?= new CommandEntry(@)
    else
      if @entry?.panel.isVisible()
        @entry.panel.hide()
      else
        @entry.panel.show()
        @entry.focusFilterEditor()

  toggleCWD: ->

    if @cwd.panel.isVisible()
      @cwd.panel.hide()
    else
      @cwd.panel.show()
      @cwd.filterEditorView.setText(@cwd.cwd())
      @cwd.setItems(atom.project.getPaths())

      @cwd.focusFilterEditor()

  runCommand: =>
    command = @entry.filterEditorView.getText()
    cwd = @cwd?.cwd() || atom.project.getPaths()[0]

    unless Utils.stringIsBlank(command)
      @commandRunnerView.runCommand(command, cwd)

  copyBuffer: =>
    atom.clipboard.write(@commandRunnerView.output)

  reRunCommand: (e) =>
    @commandRunnerView.reRunCommand(e)

  killLastCommand: =>
    @commandRunnerView.killCommand()

  storeFocusedElement: =>
    @previouslyFocused = $(':focus')

  restoreFocusedElement: =>
    if @previouslyFocused?
      @previouslyFocused.focus()
    else
      atom.workspace.focus()

  togglePanel: =>
    @commandRunnerView.togglePanel()

  show: =>
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel?.show()

    @storeFocusedElement()
    @entry.focusFilterEditor()

  hide: =>
    @entry?.hide()

  destroy: =>
    @hide()
