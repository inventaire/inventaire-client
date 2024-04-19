import { invoke } from 'underscore'
import { API } from '#app/api/api'
import { sum } from '#app/lib/utils'
import Group from '../models/group.ts'

export default Backbone.Collection.extend({
  url () { return API.groups.base },
  parse (res) { return res.groups },
  model: Group,
  otherUsersRequestsCount () { return sum(invoke(this.models, 'requestsCount')) },
  comparator: 'highlightScore',
})
