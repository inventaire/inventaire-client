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

  # Entities data are saved formatted in the LocalDb,
  # thus the need to run formatting only once
  formatIfNew: ->
    if @get '_formatted'
      # Always fired as it formats temporary data that aren't persisted to the LocalDb
      @afterFormatSync()
    else
      uri = @get 'uri'
      # Running formatSync out of a promise chain
      # as other initialization steps might depend on those sync formatted data:
      # this shouldn't thus be run on next tick
      @formatSync()
      @afterFormatSync()

      @formatAsync()
      .then @_formatted.bind(@)
      .catch _.Error("formatting new entity #{uri}")

    return

  _formatted: ->
    @set '_formatted', true
    @save()

  # placeholders to override in sub classes
  formatSync: _.noop
  formatAsync: -> _.preq.resolved
  # Data set as direct model object attributes aren't persisted on save
  # so need to be set everytimes.
  # afterFormatSync is the place where to declare those: it will be run everytime,
  # once sync formatting happened
  afterFormatSync: _.noop

customSave = ->
  app.request 'save:entity:model', @prefix, @toJSON()
