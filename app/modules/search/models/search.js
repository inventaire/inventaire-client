export default Backbone.Model.extend({
  initialize (data) {
    if (data.timestamp == null) { return this.updateTimestamp() }
  },

  savePictures (pictures) {
    const currentPictures = this.get('pictures') || []
    // no need to save more than what we need/can display
    if (currentPictures > 5) return
    pictures = _.compact(pictures)
    const updatedPictures = _.uniq(currentPictures.concat(pictures)).slice(0, 6)
    return this.set('pictures', updatedPictures)
  },

  serializeData () {
    const data = this.toJSON()
    const { query, uri } = data
    data.pathname = uri ? `/entity/${uri}` : `/search?q=${query}`
    data.pictures = _.forceArray(data.pictures)
    if (!data.label) { data.label = query }
    return data
  },

  updateTimestamp () { return this.set('timestamp', Date.now()) },

  show () {
    const [ uri, query ] = Array.from(this.gets('uri', 'query'))
    if (uri != null) {
      app.execute('show:entity', uri)
    } else { app.execute('search:global', query) }
  }
})
