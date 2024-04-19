import app from '#app/app'

// @ts-expect-error
export default Backbone.NestedModel.extend({
  initialize () {
    this.on('change:status', this.update)
  },

  beforeShow () {
    this._waitForInit = this._waitForInit || this.initSpecific()
    return this._waitForInit
  },

  update () {
    return this.collection.updateStatus(this.get('time'))
  },

  isUnread () { return this.get('status') === 'unread' },

  grabAttributeModel (attribute) {
    return app.request('waitForNetwork')
    .then(() => {
      const id = this.get(`data.${attribute}`)
      return this.reqGrab(`get:${attribute}:model`, id, attribute)
    })
  },

  grabAttributesModels (...attributes) {
    return Promise.all(attributes.map(this.grabAttributeModel.bind(this)))
  },
})
