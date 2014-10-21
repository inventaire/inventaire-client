module.exports =
  initialize: ->
    sharedLib('global_libs_extender').initialize()
    #changing the default attribute to fit CouchDB
    Backbone.Model::idAttribute = '_id'
    Backbone.Collection::findOne = -> @models[0]
    Backbone.Collection::byId = (id)-> @_byId[id]
    Backbone.Collection::byIds = (ids)-> ids.map (id)=> @byId(id)
    Marionette.Region::Show = (view, options)->
      if _.isString options then title = options
      else if options?.docTitle? then title = options.docTitle

      if title?
        app.docTitle _.softDecodeURI(title)

      return @show(view, options)

    $.postJSON = (url, body, callback)->
      if callback?
        return $.post(url, body, callback, 'json')
      else
        return $.post(url, body, 'json')

    $.getXML = (url)->
      return $.ajax
        type: 'GET',
        url: url,
        dataType: 'xml',