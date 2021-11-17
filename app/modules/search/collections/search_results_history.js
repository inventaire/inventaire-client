import { localStorageProxy } from 'lib/local_storage'
import Search from '../models/search'

export default Backbone.Collection.extend({
  model: Search,
  // deduplicating searches
  addNonExisting (data) {
    const { query, uri } = data
    let model = query ? this.where({ query })[0] : this.where({ uri })[0]

    // create the model if not existing
    if (model != null) {
      model.updateTimestamp()
    } else {
      model = this.add(data)
    }

    return model
  },

  comparator (model) { return -model.get('timestamp') },

  initialize () {
    const data = localStorageProxy.getItem('searches')
    if (data != null) {
      this.add(JSON.parse(data))
    }

    // set a high debounce to give priority to everything else
    // as writing to the local storage is blocking the thread
    // and those aren't critical data
    this.lazySave = _.debounce(this.save.bind(this), 3000)
    // Models 'change' events are propagated to the collection by Backbone
    // See https://stackoverflow.com/a/9951424/3324977
    this.on('add remove change reset', this.lazySave.bind(this))
  },

  save () {
    // Remove duplicates
    const searches = _.uniq(this.toJSON(), search => search.uri || search.query.trim().toLowerCase())
    // keep only track of the 10 last searches
    const data = JSON.stringify(searches.slice(0, 11))
    return localStorageProxy.setItem('searches', data)
  },

  findLastSearch () {
    this.sort()
    return this.models[0]
  }
})
