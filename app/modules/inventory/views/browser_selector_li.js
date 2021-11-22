import browserSelectorLiTemplate from './templates/browser_selector_li.hbs'

export default Marionette.View.extend({
  tagName: 'li',
  className: 'browser-selector-li',
  template: browserSelectorLiTemplate,

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

  selectOption () {
    this.triggerMethod('selectOption', this.model)
  }
})
