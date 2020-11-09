import { invertAttr, isOpenedOutside } from 'lib/utils'
import workLiTemplate from './templates/work_li.hbs'
import '../scss/work_li.scss'

export default Marionette.ItemView.extend({
  template: workLiTemplate,
  className () {
    const prefix = this.model.get('prefix')
    if (this.wrap == null) { this.wrap = this.options.wrap }
    const wrap = this.wrap ? 'wrapped wrappable' : ''
    return `workLi entity-prefix-${prefix} ${wrap}`
  },

  attributes () {
    // Used by deduplicate_layout
    return { 'data-uri': this.model.get('uri') }
  },

  initialize () {
    let preventRerender
    app.execute('uriLabel:update');

    ({ showAllLabels: this.showAllLabels, showActions: this.showActions, wrap: this.wrap, preventRerender } = this.options)
    if (this.showActions == null) { this.showActions = true }
    if (preventRerender == null) { preventRerender = false }

    // Allow to disable re-render for views that are used as part of layouts that store state
    // in the DOM - such as ./deduplicate_layout - so that this state isn't lost
    if (preventRerender) return

    if (this.model.usesImagesFromSubEntities) {
      this.model.fetchSubEntities()
      this.listenTo(this.model, 'change:image', this.lazyRender.bind(this))
    }

    if (this.showActions) {
      // Required by @getNetworkItemsCount
      return this.model.getItemsByCategories()
      .then(this.lazyRender.bind(this))
    }
  },

  behaviors: {
    PreventDefault: {}
  },

  ui: {
    zoomButtons: '.zoom-buttons span',
    cover: 'img'
  },

  events: {
    'click a.addToInventory': 'showItemCreationForm',
    'click .zoom-buttons': 'toggleZoom',
    click: 'toggleWrap'
  },

  onRender () {
    return this.updateClassName()
  },

  showItemCreationForm (e) {
    if (!isOpenedOutside(e)) {
      app.execute('show:item:creation:form', { entity: this.model })
    }
  },

  serializeData () {
    const attrs = _.extend(this.model.toJSON(), { showAllLabels: this.showAllLabels, showActions: this.showActions, wrap: this.wrap })
    const count = this.getNetworkItemsCount()
    if (count != null) { attrs.counter = { count, highlight: count > 0 } }
    if (attrs.extract != null) { attrs.description = attrs.extract }
    return attrs
  },

  getNetworkItemsCount () {
    const { itemsByCategory } = this.model
    if (itemsByCategory != null) {
      return itemsByCategory.network.length + itemsByCategory.personal.length
    } else {
      return 0
    }
  },

  toggleZoom (e) {
    invertAttr(this.ui.cover, 'src', 'data-zoom-toggle')
    this.ui.zoomButtons.toggle()
    this.$el.toggleClass('zoom', { duration: 500 })
    e.stopPropagation()
    e.preventDefault()
  },

  toggleWrap (e) {
    if (this.$el.hasClass('wrapped')) {
      this.wrap = false
      this.$el.removeClass('wrapped')
      this.$el.addClass('unwrapped')
    } else if (this.$el.hasClass('unwrapped')) {
      this.wrap = true
      this.$el.removeClass('unwrapped')
      this.$el.addClass('wrapped')
    }
  }
})
