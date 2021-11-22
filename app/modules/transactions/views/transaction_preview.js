import { isOpenedOutside } from 'lib/utils'
import transactionPreviewTemplate from './templates/transaction_preview.hbs'

export default Marionette.View.extend({
  template: transactionPreviewTemplate,
  className: 'transactionPreview',
  behaviors: {
    PreventDefault: {}
  },

  initialize () {
    this.listenTo(app.vent, 'transaction:select', this.autoSelect.bind(this))
    // Required by @requestContext
    this.model.buildTimeline()
  },

  serializeData () {
    return _.extend(this.model.serializeData(), {
      onItem: this.options.onItem,
      requestContext: this.requestContext()
    })
  },

  modelEvents: {
    grab: 'lazyRender',
    'change:read': 'lazyRender'
  },

  events: {
    'click .showTransaction': 'showTransaction'
  },

  ui: {
    showTransaction: 'a.showTransaction'
  },

  onRender () {
    if (app.request('last:transaction:id') === this.model.id) {
      this.$el.addClass('selected')
    }
  },

  showTransaction (e) {
    if (!isOpenedOutside(e)) {
      if (this.options.onItem) {
        app.execute('show:transaction', this.model.id)
        // Required to close the ItemShowLayout modal if one was open
        app.execute('modal:close')
      } else {
        return app.vent.trigger('transaction:select', this.model)
      }
    }
  },

  autoSelect (transac) {
    if (transac === this.model) {
      this.$el.addClass('selected')
    } else { this.$el.removeClass('selected') }
  },

  requestContext () {
    // first action context
    return this.model.timeline.models[0].context()
  }
})
