import { invertAttr, isOpenedOutside } from 'lib/utils'
import workLiTemplate from './templates/work_li.hbs'
import workLiCompactTemplate from './templates/work_li_compact.hbs'
import '../scss/work_li.scss'
import '../scss/work_li_compact.scss'
import { localStorageProxy } from 'lib/local_storage'

export default Marionette.ItemView.extend({
  className () {
    const prefix = this.model.get('prefix')
    if (this.wrap == null) this.wrap = this.options.wrap
    const wrap = this.wrap ? 'wrapped wrappable' : ''
    return `entity-prefix-${prefix} ${wrap}`
  },

  initialize () {
    this.display = localStorageProxy.getItem('entities:display') || 'cascade'
    if (this.display === 'cascade') {
      this.template = workLiTemplate
    } else if (this.display === 'table') {
      this.template = workLiCompactTemplate
    }

    this.display = localStorageProxy.getItem('entitiesDisplay') || 'entitiesLargeList'
    const workLiDisplay = this.display === 'entitiesCompactList' ? 'workLiCompact' : 'workLi'
    this.$el.addClass(workLiDisplay)
    app.execute('uriLabel:update');

    ({ showAllLabels: this.showAllLabels, showActions: this.showActions, wrap: this.wrap } = this.options)
    if (this.showActions == null) this.showActions = true

    if (this.model.usesImagesFromSubEntities) {
      this.model.fetchSubEntities()
      this.listenTo(this.model, 'change:image', this.lazyRender.bind(this))
    }

    if (this.showActions) {
      // Required by @getNetworkItemsCount
      this.model.getItemsByCategories()
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

  getTemplate () {
    if (this.display === 'entitiesCompactList') {
      return workLiCompactTemplate
    } else {
      return workLiTemplate
    }
  },

  onRender () {
    this.updateClassName()
    const workLiDisplay = this.display === 'entitiesCompactList' ? 'workLiCompact' : 'workLi'
    this.$el.addClass(workLiDisplay)
  },

  showItemCreationForm (e) {
    if (!isOpenedOutside(e)) {
      app.execute('show:item:creation:form', { entity: this.model })
    }
  },

  serializeData () {
    const attrs = _.extend(this.model.toJSON(), { showAllLabels: this.showAllLabels, showActions: this.showActions, wrap: this.wrap })
    const count = this.getNetworkItemsCount()
    if (count != null) attrs.counter = { count, highlight: count > 0 }
    if (attrs.extract != null) attrs.description = attrs.extract
    attrs.hasDescriptionAndShortTitle = attrs.label.length < 50 && attrs.description
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
