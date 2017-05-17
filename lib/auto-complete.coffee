{BufferedProcess} = require 'atom'

module.exports =
class AutoComplete

  @complete: (input, cwd, options) ->
    @process = new BufferedProcess(@params(input, cwd, options))

  @params: (input = "/", cwd, options) ->
    command: if atom.config.get("execute.shellCommand")? then atom.config.get("execute.shellCommand") else '/bin/bash'
    args: ['-c', "compgen -#{options} #{input}", '-il']
    options:
      cwd: cwd
