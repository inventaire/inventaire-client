# Inspired by http://stackoverflow.com/a/13054819/3324977
module.exports = (attributesToOmit)-> (attrs, options = {}) ->
  attrs or= _.omit @toJSON(), attributesToOmit

  options.data = JSON.stringify attrs
  options.contentType = 'application/json'

  return Backbone.Model::save.call @, attrs, options
