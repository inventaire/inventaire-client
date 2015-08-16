module.exports = Backbone.NestedModel.extend
  initLazySave: ->
    lazySave = _.debounce customSave.bind(@), 100
    @save = (args...)->
      @set.apply @, args
      lazySave()
      return @

  updateMetadata: ->
    # has to return a promise
    _.preq.start().then @executeMetadataUpdate.bind(@)

  executeMetadataUpdate: ->
    app.execute 'metadata:update',
      title: @buildBookTitle()
      description: @get('description')?[0..500]
      image: @get('pictures')?[0]
      url: @get 'canonical'

  buildBookTitle: ->
    title = @get 'title'
    "#{title} - " + _.I18n 'book'

customSave = ->
  app.request 'save:entity:model', @prefix, @toJSON()
