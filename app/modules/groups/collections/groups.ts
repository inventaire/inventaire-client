import { invoke } from 'underscore'
import app from '#app/app'
import { sum } from '#app/lib/utils'
import Group from '../models/group.ts'

export default Backbone.Collection.extend({
  url () { return app.API.groups.base },
  parse (res) { return res.groups },
  model: Group,
  otherUsersRequestsCount () { return sum(invoke(this.models, 'requestsCount')) },
  comparator: 'highlightScore',
})
