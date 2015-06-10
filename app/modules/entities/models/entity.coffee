module.exports = Backbone.NestedModel.extend
  initLazySave: ->
    lazySave = _.debounce customSave.bind(@), 100
    @save = (args...)->
      @set.apply @, args
      lazySave()
      return @

customSave = ->
  app.request 'save:entity:model', @prefix, @toJSON()
