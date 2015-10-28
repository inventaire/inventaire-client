# rely on @model.get 'uri' to be accessible
# and mainUserHasOne being called at serializeData,
# mainUserHasOne returning a boolean for templates if/else

module.exports = ->
  _.extend @events,
    'click .hasAnInstance': 'showInstance'


  _.extend @,
    mainUserHasOne: ->
      @instance = app.request 'item:main:user:instance', @model.get('uri')
      return @instance?

    showInstance: ->
      app.execute 'show:item:show:from:model', @instance

  return
