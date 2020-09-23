export default Marionette.ItemView.extend({
  template: require('./templates/entity_actions'),
  className: 'entityActions',
  behaviors: {
    PreventDefault: {}
  },

  initialize () {
    return this.uri = this.model.get('uri')
  },

  serializeData () {
    const { itemToUpdate } = this.options
    return { itemToUpdate }
  },

  events: {
    'click .add': 'add',
    'click .updateItem': 'updateItem'
  },

  add () { return app.execute('show:item:creation:form', { entity: this.model }) },
  updateItem () { return app.request('item:update:entity', this.options.itemToUpdate, this.model) }
})
