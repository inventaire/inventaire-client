/* eslint-disable
    import/no-duplicates,
    no-undef,
    no-unused-vars,
    no-var,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import getBestLangValue from 'modules/entities/lib/get_best_lang_value'

export default Backbone.Model.extend({
  initialize (data) {
    // Track TypeErrors where typeFormatters[data.type] isn't a function
    try { return this.set(typeFormatters[data.type](data)) } catch (err) {
      err.context = { data }
      throw err
    }
  }
})

const entityFormatter = (type, typeAlias) => function (data) {
  data.typeAlias = typeAlias || type
  data.pathname = `/entity/${data.uri}`
  return data
}

var typeFormatters = {
  works: entityFormatter('work', 'book'),
  humans: entityFormatter('author'),
  series: entityFormatter('serie'),
  collections: entityFormatter('collection'),
  publishers: entityFormatter('publisher'),
  users (data) {
    data.typeAlias = 'user'
    // label is the username
    data.pathname = `/inventory/${data.label}`
    return data
  },

  groups (data) {
    data.typeAlias = 'group'
    data.pathname = `/groups/${data.id}`
    return data
  },

  subjects (data) {
    data.typeAlias = 'subject'
    data.pathname = `/entity/wdt:P921-${data.uri}`
    // Let app/lib/shared/api/img.coffee request to be redirected
    // to the associated entity image
    data.image = data.uri
    return data
  }
}
