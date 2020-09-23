/* eslint-disable
    import/no-duplicates,
    no-undef,
    no-var,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import AuthorsPreviewList from 'modules/entities/views/authors_preview_list'

export default function (authorsPerProperty) {
  return (() => {
    const result = []
    for (const property in authorsPerProperty) {
      const models = authorsPerProperty[property]
      result.push(showAuthorsPreviewList.call(this, property, models))
    }
    return result
  })()
};

var showAuthorsPreviewList = function (property, models) {
  if (models.length === 0) { return }
  const collection = new Backbone.Collection(models)
  const name = extendedAuthorsKeys[property]
  return this[name].show(new AuthorsPreviewList({ collection, name }))
}

var extendedAuthorsKeys = {
  'wdt:P50': 'authors',
  'wdt:P58': 'scenarists',
  'wdt:P110': 'illustrators',
  'wdt:P6338': 'colorists'
}
