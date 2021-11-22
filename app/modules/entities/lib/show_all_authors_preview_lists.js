import AuthorsPreviewList from 'modules/entities/views/authors_preview_list'

export default function (authorsPerProperty) {
  for (const property in authorsPerProperty) {
    const models = authorsPerProperty[property]
    showAuthorsPreviewList.call(this, property, models)
  }
}

const showAuthorsPreviewList = function (property, models) {
  if (models.length === 0) return
  const collection = new Backbone.Collection(models)
  const name = extendedAuthorsKeys[property]
  this.showChildView(name, new AuthorsPreviewList({ collection, name }))
}

const extendedAuthorsKeys = {
  'wdt:P50': 'authors',
  'wdt:P58': 'scenarists',
  'wdt:P110': 'illustrators',
  'wdt:P6338': 'colorists'
}
