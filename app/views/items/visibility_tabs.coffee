module.exports = class VisibilityTabs extends Backbone.Marionette.ItemView
  template: require 'views/items/templates/visibility_tabs'
  initialize: -> @addMultipleSelectorEvents()
  multipleSelectorEvents:
    'click #noVisibilityFilter #private #contacts #public': 'updateVisibilityTabs'

  updateVisibilityTabs: (e)->
    visibility = $(e.currentTarget).attr 'id'
    if visibility is 'noVisibilityFilter'
      app.commands.execute 'filter:visibility:reset'
    else
      app.commands.execute 'filter:visibility', visibility

    $('#visibility-tabs li').removeClass 'active'
    $(e.currentTarget).find('li').addClass 'active'