/* eslint-disable
    no-return-assign,
    no-undef,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
export default Marionette.CompositeView.extend({
  className () {
    let classes = 'entity-history'
    if (this.options.standalone) { classes += ' standalone' }
    return classes
  },
  template: require('./templates/history'),
  childViewContainer: '.inner-history',
  childView: require('./version'),
  initialize () {
    let uri;
    ({ model: this.model, uri } = this.options)
    if (this.model) { this.collection = this.model.history }
    return this.redirectUri = uri !== this.model.get('uri') ? uri : undefined
  },

  serializeData () {
    const attrs = this.model?.toJSON() || {}
    return _.extend(attrs, {
      standalone: this.options.standalone,
      label: (this.redirectUri != null) ? this.redirectUri : attrs.label
    }
    )
  }
})
