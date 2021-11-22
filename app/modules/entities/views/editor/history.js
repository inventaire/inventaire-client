import Version from './version'
import historyTemplate from './templates/history.hbs'
import 'modules/entities/scss/history.scss'

export default Marionette.CollectionView.extend({
  className () {
    let classes = 'entity-history'
    if (this.options.standalone) classes += ' standalone'
    return classes
  },
  template: historyTemplate,
  childViewContainer: '.inner-history',
  childView: Version,
  initialize () {
    let uri;
    ({ model: this.model, uri } = this.options)
    if (this.model) this.collection = this.model.history
    this.redirectUri = uri !== this.model.get('uri') ? uri : undefined
  },

  serializeData () {
    const attrs = this.model?.toJSON() || {}
    return _.extend(attrs, {
      standalone: this.options.standalone,
      label: (this.redirectUri != null) ? this.redirectUri : attrs.label,
      hasAdminAccess: app.user.hasAdminAccess
    })
  }
})
