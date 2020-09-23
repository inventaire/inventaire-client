/* eslint-disable
    no-undef,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
export default Backbone.Collection.extend({
  url () { return app.API.groups.base },
  parse (res) { return res.groups },
  model: require('../models/group'),
  otherUsersRequestsCount () { return _.sum(_.invoke(this.models, 'requestsCount')) },
  comparator: 'highlightScore'
})
