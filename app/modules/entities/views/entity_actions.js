import entityActionsTemplate from './templates/entity_actions.hbs'
import '../scss/entity_actions.scss'

export default Marionette.ItemView.extend({
  template: entityActionsTemplate,
  className: 'entityActions',
  behaviors: {
    PreventDefault: {}
  },

  initialize () {
    this.uri = this.model.get('uri')
  },

  serializeData () {
    const { itemToUpdate } = this.options
    return { itemToUpdate }
  },

  events: {
    'click .add': 'add',
    'click .updateItem': 'updateItem'
  },

  add () {
    app.execute('show:item:creation:form', { entity: this.model })
  },

  updateItem () {
    app.request('item:update:entity', this.options.itemToUpdate, this.model)
  }
})
