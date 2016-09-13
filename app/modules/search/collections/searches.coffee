module.exports = Backbone.Collection.extend
  model: require '../models/search'
  # dedupplicating searches
  addNonExisting: (data)->
    { query } = data
    model = @where({ query })[0]

    # create the model if not existing
    if model? then model.updateTimestamp()
    else model = @add data

    return model

  comparator: (model)-> - model.get('timestamp')

  initialize: ->
    data = localStorageProxy.getItem 'searches'
    if data?
      @add JSON.parse(data)

    # set a high debounce to give priority to everything else
    # as writing to the local storage is blocking the thread
    # and those aren't critical data
    @lazySave = _.debounce @save.bind(@), 3000
    # Models 'change' events are propagated to the collection by Backbone
    # see http://stackoverflow.com/a/9951424/3324977
    @on 'add remove change reset', @lazySave.bind(@)

  save: ->
    # keep only track of the 10 last searches
    data = JSON.stringify @toJSON()[0..10]
    localStorageProxy.setItem 'searches', data

  findLastSearch: ->
    @sort()
    return @models[0]
