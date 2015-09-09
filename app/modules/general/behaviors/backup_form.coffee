module.exports = Marionette.Behavior.extend
  events:
    'change input': 'backup'

  _backup: {}

  backup: (e)->
    _.log @_backup, '@_backup'
    { id, value, type } = e.currentTarget
    if type is 'text'
      @_backup[id] = value

  recover: ->
    _.log @_backup, '@_backup'
    for id, value of @_backup
      _.log value, id
      @$el.find("##{id}").val value

  onRender: -> @recover()
