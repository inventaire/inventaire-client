module.exports = Marionette.ItemView.extend
  template: require './templates/edition_li'
  tagName: -> if @options.standalone then 'div' else 'li'
  className: -> if @options.standalone then 'editionLayout' else 'editionLi'

  initialize: ->
    @standalone = @options.standalone

  onShow: ->
    if @standalone
      @model.waitForWork
      .then @render.bind(@)

  serializeData: ->
    _.extend @model.toJSON(),
      standalone: @standalone
      work: if @standalone then @model.work?.toJSON()

  events:
    'click .add': 'add'

  add: -> app.execute 'show:item:creation:form', { entity: @model }
