WorkData = require './work_data'
WorkActions = require './work_actions'

module.exports = Marionette.LayoutView.extend
  template: require './templates/work_layout'
  regions:
    workData: '#workData'
    workActions: '#workActions'

  behaviors:
    WikiBar: {}

  serializeData: ->
    _.extend @model.toJSON(),
      canRefreshData: true

  initialize: ->
    @uri = @model.get('uri')
    app.execute 'metadata:update:needed'

  onShow: ->
    @showWorkData()
    # need to wait to know if the user has an instance of this work
    app.request('wait:for', 'user').then @showWorkActions.bind(@)

    @model.updateMetadata()
    .finally app.Execute('metadata:update:done')

  events:
    'click a.showWikipediaPreview': 'toggleWikipediaPreview'
    'click .refreshData': 'refreshData'

  showWorkData: ->
    @workData.show new WorkData
      model: @model
      workPage: true


  showWorkActions: -> @workActions.show new WorkActions { model: @model }

  toggleWikipediaPreview: -> @$el.trigger 'toggleWikiIframe', @

  refreshData: -> app.execute 'show:entity:refresh', @model
