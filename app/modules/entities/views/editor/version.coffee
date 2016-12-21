module.exports = Marionette.ItemView.extend
  className: 'version'
  template: require './templates/version'
  initialize: ->
    @lazyRender = _.LazyRender @

  serializeData: -> @model.serializeData()
  onShow: ->
    @listenTo @model, 'grab', @lazyRender
