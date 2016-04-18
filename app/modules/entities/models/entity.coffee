Filterable = require 'modules/general/models/filterable'

module.exports = Filterable.extend
  initLazySave: ->
    lazySave = _.debounce customSave.bind(@), 100
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

customSave = ->
  app.request 'save:entity:model', @prefix, @toJSON()
