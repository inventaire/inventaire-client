# A behavior to preserve input text from being lost on a view re-render
# by saving it at every change and recovering it on re-render
# This behavior should probably be added to any view with input or textarea
# that is suceptible to be re-rendered due to some event listener
module.exports = Marionette.Behavior.extend
  events:
    'change input, textarea': 'backup'
    'click a': 'forget'

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
    customRecover @$el, @_backup.byId, buildIdSelector
    customRecover @$el, @_backup.byName, buildNameSelector

  # Listen on clicks on anchor with a 'data-forget' attribute
  # to delete the data associated with the form element related to this anchor.
  # Typically used on 'cancel' buttons
  forget: (e)->
    forgetAttr = e.currentTarget.attributes['data-forget']?.value
    if forgetAttr?
      _.log forgetAttr, 'form:forget'
      if forgetAttr[0] is '#'
        id = forgetAttr.slice(1)
        delete @_backup.byId[id]
      else
        name = forgetAttr
        delete @_backup.byName[name]

  onRender: -> @recover()

customRecover = ($el, store, selectorBuilder)->
  for key, value of store
    _.log value, key
    selector = selectorBuilder key
    $el.find(selector).val value

buildIdSelector = (id)-> "##{id}"
buildNameSelector = (name)-> "[name='#{name}']"
