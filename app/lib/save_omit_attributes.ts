import { omit } from 'underscore'
// Inspired by https://stackoverflow.com/a/13054819/3324977
export default attributesToOmit => function (attrs, options = {}) {
  if (!attrs) attrs = omit(this.toJSON(), attributesToOmit)

  // @ts-expect-error
  options.data = JSON.stringify(attrs)
  // @ts-expect-error
  options.contentType = 'application/json'

  return Backbone.Model.prototype.save.call(this, attrs, options)
}
