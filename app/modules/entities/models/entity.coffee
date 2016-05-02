module.exports = Backbone.NestedModel.extend
  initLazySave: ->
    lazySave = _.debounce customSave.bind(@), 1000
    @save = (args...)->
      @set.apply @, args
      lazySave()
      return @

  updateMetadata: ->
    # has to return a promise
    _.preq.start.then @executeMetadataUpdate.bind(@)

  executeMetadataUpdate: ->
    app.execute 'metadata:update',
      title: @buildBookTitle()
      description: @findBestDescription()?[0..500]
      image: @get('pictures')?[0]
      url: @get 'canonical'

  # required, as used on entities in general
  # ex: on Item model
  findBestDescription: -> @get 'description'

  buildBookTitle: ->
    title = @get 'title'
    "#{title} - " + _.I18n 'book'

  formatIfNew: ->
    # data that are @set during @format don't need to be re-set when
    # the model was cached in app.entities local/temporary collections
    unless @get '_formatted'
      uri = @get 'uri'
      # # handle both sync and async @format functions as async
      _.preq.start
      .then @format.bind(@)
      .then =>
         @set '_formatted', true
         @save()
      .catch _.Error("formatting new entity #{uri}")

customSave = ->
  app.request 'save:entity:model', @prefix, @toJSON()
