{SelectListView} = require 'atom-space-pen-views'

AC = require './auto-complete'
Utils = require './utils'
path = require('path');

module.exports =
class CWDView extends SelectListView
 initialize: ->
   super
   @addClass('overlay from-top')
   @setItems(atom.project.getPaths())
   @filterEditorView.setText(atom.project.getPaths()[0])
   @panel = atom.workspace.addModalPanel(item: this)
   @focusFilterEditor()
   @panel.show()

   @.on 'keydown', (e) =>
     if e.keyCode is 9
       e.preventDefault()
       @autoComplete()
     else if e.keyCode is 27
       if @previousElement?
         @previousElement.focus()
       @panel.hide()

   @on 'blur', =>
     @panel.hide()

  viewForItem: (item) ->
    "<li>#{item}</li>"

  confirmed: (item) ->
    @selected = @filterEditorView.getText()
    @selected = path.resolve(@selected)
    @panel.hide()
    atom.views.getView(atom.workspace).focus()

  cwd: ->
    @selected || ''

  autoComplete: =>
    cwd = @cwd() || atom.project.getPaths()[0]
    wordRegex =
      wordRegex: /[\s]/
    # Get the beginning of the current word
    @start = @filterEditorView.getModel().getLastCursor().getBeginningOfCurrentWordBufferPosition(wordRegex).column
    # Get the end of the current word
    @end = @filterEditorView.getModel().getLastCursor().getEndOfCurrentWordBufferPosition(wordRegex).column
    @current_directory = @filterEditorView.getText().slice(@start, @end)

    @autocomplete = AC.complete(@current_directory, cwd, "d")
    @autocomplete.process.stdout.on 'data', @updateCommand

  updateCommand: (output) =>

    # Get an array to populate
    output = output.toString().split("\n")

    # Remove the last empty element
    output.pop()

    # Make the array unique
    output = Utils.uniq(output)

    # Populate the list
    @setItems(output)

    # Set text to largext common substring
    suggested_command = Utils.commonPrefix(output)

    # Replace current word with new command if there's a suggestion
    output = [@filterEditorView.getText().slice(0, @start + 1), suggested_command, @filterEditorView.getText().slice(@start)].join('');
    new_command = Utils.replaceAt(@filterEditorView.getText(), @start, @end, suggested_command)

    # Set the text
    @filterEditorView.setText(new_command)
