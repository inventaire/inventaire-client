/* eslint-disable
    no-undef,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
export default Marionette.ItemView.extend({
  template: require('./templates/article_li'),
  className: 'articleLi',
  serializeData () {
    const attrs = this.model.toJSON()
    return _.extend(attrs, {
      href: this.getHref(),
      hasDate: this.hasDate(),
      hideRefreshButton: true
    }
    )
  },

  getHref () {
    const DOI = this.model.get('claims.wdt:P356.0')
    if (DOI != null) { return `https://dx.doi.org/${DOI}` }
  },

  hasDate () { return (this.model.get('claims.wdt:P577.0') != null) }
})
