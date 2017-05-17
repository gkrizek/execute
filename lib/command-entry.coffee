{SelectListView} = require 'atom-space-pen-views'

AC = require './auto-complete'
Utils = require './utils'

module.exports =
class CommandEntry extends SelectListView
  initialize: (CommandEntryView) ->
    super
    @addClass('overlay from-top')
    @setItems([])
    @panel = atom.workspace.addModalPanel(item: this)
    @focusFilterEditor()
    @panel.show()

    @on 'blur', =>
      @panel.hide()

    @.on 'keydown', (e) =>
      if e.keyCode is 9
        e.preventDefault()
        @autoComplete()
      else if e.keyCode is 13
        @confirmed(@filterEditorView.getText())
        CommandEntryView.runCommand(@filterEditorView.getText())
        @panel.hide()
      else if e.keyCode is 27
        @panel.hide()

  viewForItem: (item) ->
    "<li>#{item}</li>"

  confirmed: (item) ->
    @selected = item

  getEmptyMessage: () ->
    "Commands"

  getFilterQuery: () =>
    if @current_command?
      return @current_command
    @filterEditorView.getText()

  autoComplete: =>
    cwd = @cwd?.cwd() || atom.project.getPaths()[0]
    wordRegex =
      wordRegex: /[\s]/
    # Get the beginning of the current word
    @start = @filterEditorView.getModel().getLastCursor().getBeginningOfCurrentWordBufferPosition(wordRegex).column
    # Get the end of the current word
    @end = @filterEditorView.getModel().getLastCursor().getEndOfCurrentWordBufferPosition(wordRegex).column
    @current_command = @filterEditorView.getText().slice(@start, @end)

    @autocomplete = AC.complete(@current_command, cwd, "cfd")
    @autocomplete.process.stdout.on 'data', @updateCommand

  updateCommand: (output) =>

    # Get an array to populate
    output = output.toString().split("\n")

    # Remove the last empty element
    output.pop()

    # Populate the list
    @setItems(output)

    # Make the array unique
    output = Utils.uniq(output)

    # Set text to largext common substring
    suggested_command = Utils.commonPrefix(output)

    # Replace current word with new command if there's a suggestion
    output = [@filterEditorView.getText().slice(0, @start + 1), suggested_command, @filterEditorView.getText().slice(@start)].join('');
    new_command = Utils.replaceAt(@filterEditorView.getText(), @start, @end, suggested_command)

    # Set the text
    @filterEditorView.setText(new_command)
