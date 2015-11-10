module.exports = Marionette.Behavior.extend
  events:
    'change input, textarea': 'backup'

  initialize: ->
    @_backup =
      byId: {}
      byName: {}

  backup: (e)->
    # _.log @_backup, 'backup form data'
    { id, value, type, name } = e.currentTarget

    unless _.isNonEmptyString value then return
    unless type is 'text' or type is 'textarea' then return

    if _.isNonEmptyString id then @_backup.byId[id] = value
    else if _.isNonEmptyString name then @_backup.byName[name] = value

  recover: ->
    _.log @_backup, 'recovering form data'
    customRecover @$el, @_backup.byId, buildIdSelector
    customRecover @$el, @_backup.byName, buildNameSelector

  onRender: -> @recover()

customRecover = ($el, store, selectorBuilder)->
  for key, value of store
    _.log value, key
    selector = selectorBuilder key
    $el.find(selector).val value

buildIdSelector = (id)-> "##{id}"
buildNameSelector = (name)-> "[name='#{name}']"
