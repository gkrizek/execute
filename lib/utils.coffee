module.exports =
class Utils

  @clean = (strings) ->
    result = (string for string in strings when !string.match(/\s+/))

  @commonPrefix = (words) ->
    max_word = words.reduce((a, b) ->
      if a > b then a else b
    )
    prefix = words.reduce((a, b) ->
      if a > b then b else a
    )
    # min word
    while max_word.indexOf(prefix) != 0
      prefix = prefix.slice(0, -1)
    prefix

  @uniq = (array) ->
    array.reduce ((p, c) ->
      if p.indexOf(c) < 0
        p.push c
      p
    ), []

  @replaceAt = (string, start, end, replacement) ->
    unless start is 0
      return string.substring(0, start) + " " + replacement + string.substring(end);
    else
      return string.substring(0, start) + replacement + string.substring(end);


  @stringIsBlank: (str)->
    !str or /^\s*$/.test str

  @colorize: (str) ->
    # Get the color code and wrap the element with the associated span
    colors =
      0:  'reset',
      1:  'bold',
      3:  'italics',
      4:  'underline',
      7:  'inverse', # foreground and background flip
      9:  'strikethrough',
      22: 'no-bold',
      23: 'no-italics',
      24: 'no-underline',
      27: 'no-inverse',
      29: 'no-strikethrough',
      30: 'black',
      31: 'red',
      32: 'green',
      33: 'yellow',
      34: 'blue',
      35: 'purple',
      36: 'cyan',
      37: 'white',
      39: 'default',
      40: 'background-black',
      41: 'background-red',
      42: 'background-green',
      43: 'background-yellow',
      44: 'background-blue',
      45: 'background-purple',
      46: 'background-cyan',
      47: 'background-white',
      49: 'background-default'

    str.replace /\[(\d+)m([^\[]*)/g, (match, color, string) ->
      return "<span class=\"execute-#{colors[color]}\">#{string}</span>"
