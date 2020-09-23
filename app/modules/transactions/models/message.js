export default Backbone.Model.extend({
  initialize () {
    return this.reqGrab('get:user:model', this.get('user'), 'user')
  },

  serializeData () {
    return _.extend(this.toJSON(),
      { user: this.user?.serializeData() })
  }
})
