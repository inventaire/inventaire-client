module.exports = Marionette.ItemView.extend
  template: require './templates/inventory_nav'
  initialize: ->
    { @section } = @options
    @section or= 'user'

  serializeData: ->
    user: app.user.toJSON()
    section: @section

  events:
    'click #tabs a': 'selectTab'

  selectTab: (e)->
    if _.isOpenedOutside e then return
    section = e.currentTarget.id.replace 'Tab', ''
    app.execute 'show:inventory', { section }
    e.preventDefault()
