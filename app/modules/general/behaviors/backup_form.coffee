module.exports = Marionette.Behavior.extend
  events:
    'change input': 'backup'

  initialize: -> @_backup = {}

  backup: (e)->
    _.log @_backup, 'backup form data'
    { id, value, type } = e.currentTarget
    if type is 'text'
      @_backup[id] = value

  recover: ->
    _.log @_backup, 'recovering form data'
    for id, value of @_backup
      _.log value, id
      @$el.find("##{id}").val value

  onRender: -> @recover()
