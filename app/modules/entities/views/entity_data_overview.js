import clampedExtract from '../lib/clamped_extract'
import entityDataOverviewTemplate from './templates/entity_data_overview.hbs'
import '../scss/entity_data_overview.scss'

export default Marionette.ItemView.extend({
  template: entityDataOverviewTemplate,
  className: 'entityDataOverview',
  initialize (options) {
    this.hidePicture = options.hidePicture
    if (!this.hidePicture) {
      this.listenTo(this.model, 'add:pictures', this.lazyRender.bind(this))
    }
  },

  modelEvents: {
    change: 'lazyRender'
  },

  serializeData () {
    const attrs = this.model.toJSON()
    clampedExtract.setAttributes(attrs)
    attrs.standalone = this.options.standalone
    attrs.hidePicture = this.hidePicture
    return attrs
  },

  behaviors: {
    PreventDefault: {},
    ClampedExtract: {}
  },

  onRender () {
    app.execute('uriLabel:update')
  }
})
