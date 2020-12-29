import log_ from 'lib/loggers'
import preq from 'lib/preq'
import searchType from '../lib/search/search_type'
import { getEntityUri } from '../lib/search/entities_uris_results'
import AuthorLayout from './author_layout'
import NoItem from 'modules/inventory/views/no_item'
import behaviorsPlugin from 'modules/general/plugins/behaviors'
import deduplicateAuthorsTemplate from './templates/deduplicate_authors.hbs'

const { startLoading, stopLoading } = behaviorsPlugin

const searchHumans = searchType('humans')

export default Marionette.CompositeView.extend({
  id: 'deduplicateAuthors',
  template: deduplicateAuthorsTemplate,
  childViewContainer: '.authors',
  childView: AuthorLayout,
  // Lazy empty view: not really fitting the context
  // but just showing that nothing was found
  emptyView: NoItem,
  behaviors: {
    Loading: {}
  },

  childViewOptions: {
    showActions: false
  },

  initialize () {
    this.collection = new Backbone.Collection()
    const { name } = this.options
    if (name != null) {
      this.showName(name)
    } else {
      this.fetchNames()
    }
  },

  async fetchNames () {
    startLoading.call(this, '.authors-loading')

    const { names } = await preq.get(app.API.entities.duplicates)
    log_.info(names, 'names')
    stopLoading.call(this)
    this.names = names
    this.render()
  },

  serializeData () { return { names: this.names } },

  events: {
    'click .name': 'showNameFromEvent'
  },

  showNameFromEvent (e) {
    const name = e.currentTarget.attributes['data-key'].value
    $(e.currentTarget).addClass('visited')
    this.showName(name)
  },

  showName (name) {
    this.collection.reset()
    startLoading.call(this, '.authors-loading')

    app.execute('querystring:set', 'name', name)

    return this.getHomonyms(name)
    .then(stopLoading.bind(this))
  },

  getHomonyms (name) {
    return searchHumans(name, 100)
    .then(humans => {
      // If there are many candidates, keep only those that look the closest, if any
      if (humans.length > 50) {
        const subset = humans.filter(asNameMatch(name))
        if (subset.length > 1) humans = subset
      }

      // If there are still many candidates, truncate the list to make it less
      // resource intensive
      if (humans.length > 50) humans = humans.slice(0, 51)

      const uris = humans.map(human => getEntityUri(human.id || human._id))

      return app.request('get:entities:models', { uris })
      .then(log_.Info('humans models'))
      .then(this.collection.add.bind(this.collection))
    })
  },

  setFilter (filter) {
    this.filter = filter
    this.render()
  }
})

const asNameMatch = name => human => _.any(_.values(human.labels), labelMatch(name))

const labelMatch = name => label => normalize(label) === normalize(name)

const normalize = name => {
  return name
  .trim()
  // Remove single letter for second names 'L.'
  .replace(/\s\w{1}\.\s?/g, ' ')
  // remove double spaces
  .replace(/\s\s/g, ' ')
  // remove special characters
  .replace(/[./\\,]/g, '')
  .toLowerCase()
}
