{WorkspaceView, Workspace, Editor} = require 'atom'
RunCommand = require '../lib/execute'

# Use the command `window:command-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "CommandRunner", ->
  activationPromise = null

  beforeEach ->
    activationPromise = atom.packages.activatePackage('execute')

  xit "will eventually have tests"
