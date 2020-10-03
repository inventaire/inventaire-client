import { sum } from 'lib/utils'
export default Backbone.Collection.extend({
  url () { return app.API.groups.base },
  parse (res) { return res.groups },
  model: require('../models/group'),
  otherUsersRequestsCount () { return sum(_.invoke(this.models, 'requestsCount')) },
  comparator: 'highlightScore'
})
