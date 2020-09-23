module.exports = ->
  [ itemId, ownerId, requesterId ] = @gets 'item', 'owner', 'requester'
  { item, owner, requester } = @get 'snapshot'
  @set
    'snapshot.item': formatSnapshotItem itemId, item
    'snapshot.owner': formatSnapshotUser ownerId, owner, 'owner'
    'snapshot.requester': formatSnapshotUser requesterId, requester, 'requester'

formatSnapshotItem = (itemId, data)->
  data.pathname = '/items/' + itemId
  return data

formatSnapshotUser = (userId, data, role)->
  data.pathname = '/inventory/' + userId
  return data
