// Inspired by http://stackoverflow.com/a/13054819/3324977
export default attributesToOmit => function (attrs, options = {}) {
  if (!attrs) { attrs = _.omit(this.toJSON(), attributesToOmit) }

  options.data = JSON.stringify(attrs)
  options.contentType = 'application/json'

  return Backbone.Model.prototype.save.call(this, attrs, options)
}
