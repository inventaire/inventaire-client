import serieCleanupAuthorTemplate from './templates/serie_cleanup_author.hbs'
import serieCleanupAuthorsTemplate from './templates/serie_cleanup_authors.hbs'

const SerieCleanupAuthor = Marionette.ItemView.extend({
  template: serieCleanupAuthorTemplate,
  className () {
    let base = 'serie-cleanup-author'
    if (this.options.isSuggestion) { base += ' suggestion' }
    return base
  },

  attributes () {
    return { 'data-uri': this.model.get('uri') }
  },

  serializeData () {
    return {
      uri: this.model.get('uri'),
      isSuggestion: this.options.isSuggestion
    }
  }
})

const AuthorsList = Marionette.CollectionView.extend({
  childView: SerieCleanupAuthor,
  childViewOptions () {
    return { isSuggestion: this.options.name === 'authorsSuggestions' }
  }
})

export default Marionette.LayoutView.extend({
  template: serieCleanupAuthorsTemplate,
  regions: {
    currentAuthorsRegion: '.currentAuthors',
    authorsSuggestionsRegion: '.authorsSuggestions'
  },

  onShow () {
    this.showList('currentAuthors')
    this.showList('authorsSuggestions')
  },

  showList (name) {
    const collection = this[`${name}Collection`] || (this[`${name}Collection`] = this.buildCollection(name))
    return this[`${name}Region`].show(new AuthorsList({ collection, name }))
  },

  buildCollection (name) {
    const uris = this.options[`${name}Uris`]
    const authorsData = uris.map(uri => ({
      uri
    }))
    return new Backbone.Collection(authorsData)
  },

  events: {
    'click .suggestion': 'add'
  },

  add (e) {
    const uri = e.currentTarget.attributes['data-uri'].value
    const model = this.authorsSuggestionsCollection.findWhere({ uri })

    this.authorsSuggestionsCollection.remove(model)
    this.currentAuthorsCollection.add(model)

    const rollback = () => {
      this.authorsSuggestionsCollection.add(model)
      return this.currentAuthorsCollection.remove(model)
    }

    return this.options.work.setPropertyValue('wdt:P50', null, uri)
    .catch(rollback)
  }
})
