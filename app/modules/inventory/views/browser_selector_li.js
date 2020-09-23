export default Marionette.ItemView.extend({
  tagName: 'li',
  className: 'browser-selector-li',
  template: require('./templates/browser_selector_li'),

  serializeData () {
    const attrs = this.model.toJSON()
    return {
      // Adapting for entities, users, and groups
      label: attrs.label || attrs.username || attrs.name,
      count: this.model._intersectionCount || attrs.count || attrs.itemsCount,
      // Only entities will have an URI
      uri: attrs.uri,
      // Only 'nearby'
      icon: attrs.icon,
      image: attrs.image?.url || attrs.picture
    }
  },

  events: {
    click: 'selectOption'
  },

  selectOption () { return this.triggerMethod('selectOption', this.model) }
})
