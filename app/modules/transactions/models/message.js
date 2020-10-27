export default Backbone.Model.extend({
  initialize () {
    this.reqGrab('get:user:model', this.get('user'), 'user')
  },

  serializeData () {
    return _.extend(this.toJSON(),
      { user: this.user?.serializeData() })
  }
})
