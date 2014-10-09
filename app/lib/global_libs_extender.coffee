module.exports =
  initialize: ->
    sharedLib('global_libs_extender').initialize()
    #changing the default attribute to fit CouchDB
    Backbone.Model::idAttribute = '_id'
    Backbone.Collection::findOne = -> @models[0]
    Backbone.Collection::byId = (id)-> @_byId[id]
    Backbone.Collection::byIds = (ids)-> ids.map (id)=> @byId(id)
    Backbone.Collection::modelsStatus = (ids)->
      models = ids.map (id)=> @byId(id) or id
      missing = models.filter (model)-> _.isString model
      cached = models.filter (model)-> _.isObject model
      return [cached, missing]

    Marionette.Region::Show = (view, options)->
      if _.isString options then title = options
      else if options?.docTitle? then title = options.docTitle

      if title?
        app.docTitle title.replace(/_/g,' ')

      return @show(view, options)

    $.postJSON = (url, body, callback)->
      if callback?
        return $.post(url, body, callback, 'json')
      else
        return $.post(url, body, 'json')