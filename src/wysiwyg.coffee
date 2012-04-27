$ = @jQuery or require('jquery')

class Wysiwyg
  className: 'wysiwyg'

  events:
    'click [data-type=bold]': 'bold'
    'click [data-type=italic]': 'italic'
    'click [data-type=list]': 'list'
    'click [data-type=link]': 'link'
    'click [data-type=h2]': 'h2'
    'click [data-type=h3]': 'h3'
    'click a': 'cancel'

  document: document

  constructor: (@options = {}) ->
    @el = $('<div />')

    for key, value of @options
      @[key] = value

    @el.addClass(@className)
    @delegateEvents(@events)
    @render()

  render: ->
    @el.empty()
    @el.append('<a href="#" data-type="bold">Bold</a>')
    @el.append('<a href="#" data-type="italic">Italic</a>')
    @el.append('<a href="#" data-type="list">List</a>')
    @el.append('<a href="#" data-type="link">Link</a>')
    @el.append('<a href="#" data-type="h2">Large</a>')
    @el.append('<a href="#" data-type="h3">Medium</a>')
    this

  bold: (e) ->
    e.preventDefault()
    return unless @selectTest()
    @exec 'bold'

  italic: (e) ->
    e.preventDefault()
    return unless @selectTest()
    @exec 'italic'

  list: (e) ->
    e.preventDefault()
    @exec 'insertUnorderedList'

  link: (e) ->
    e.preventDefault()
    return unless @selectTest()

    @exec 'unlink'
    href = prompt('Enter a link:', 'http://')
    return if not href or href is 'http://'
    href = 'http://' + href  unless (/:\/\//).test(href)
    @exec 'createLink', href

  h2: (e) ->
    e.preventDefault()
    if @query('formatBlock') is 'h2'
      @exec 'formatBlock', 'p'
    else
      @exec 'formatBlock', 'h2'

  h3: (e) ->
    e.preventDefault()
    if @query('formatBlock') is 'h3'
      @exec 'formatBlock', 'p'
    else
      @exec 'formatBlock', 'h3'

  move: (position) ->
    @el.css(position)

  # Private

  cancel: (e) ->
    e.preventDefault()
    e.stopImmediatePropagation()

  getSelectedText: ->
    if @document?.selection
      document.selection.createRange().text
    else if @document
      document.getSelection().toString()

  selectTest: ->
    if @getSelectedText().length is 0
      alert 'Select some text first.'
      return false
    true

  exec: (type, arg = null) ->
    @document.execCommand(type, false, arg)

  query: (type) ->
    @document.queryCommandValue(type)

  delegateEvents: (events) ->
    for key, method of events

      unless typeof(method) is 'function'
        # Always return true from event handlers
        method = do (method) => =>
          @[method].apply(this, arguments)
          true

      match      = key.match(/^(\S+)\s*(.*)$/)
      eventName  = match[1]
      selector   = match[2]

      if selector is ''
        @el.bind(eventName, method)
      else
        @el.delegate(selector, eventName, method)

# Expose library
if module?
  module.exports = Wysiwyg
else
  @Wysiwyg = Wysiwyg