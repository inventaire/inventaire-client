module.exports = Marionette.ItemView.extend
  className: 'userContribution'
  template: require './templates/user_contribution'
  tagName: 'li'

  ui:
    operations: '.operations'
    togglers: '.togglers span'

  initialize: ->
    @lazyRender = _.LazyRender @
    @listenTo @model, 'grab', @lazyRender

  serializeData: -> @model.serializeData()

  events:
    'click .header': 'toggleOperations'

  toggleOperations: (e)->
    # Prevent toggling when the intent was clicking on a link
    if e.target.tagName is 'A' then return

    @ui.operations.toggleClass 'hidden'
    @ui.togglers.toggleClass 'hidden'
