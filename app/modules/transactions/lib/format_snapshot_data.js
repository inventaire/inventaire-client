export default function () {
  const [ itemId, ownerId, requesterId ] = this.gets('item', 'owner', 'requester')
  const { item, owner, requester } = this.get('snapshot')
  this.set({
    'snapshot.item': formatSnapshotItem(itemId, item),
    'snapshot.owner': formatSnapshotUser(ownerId, owner, 'owner'),
    'snapshot.requester': formatSnapshotUser(requesterId, requester, 'requester')
  })
}

const formatSnapshotItem = function (itemId, data) {
  data.pathname = '/items/' + itemId
  return data
}

const formatSnapshotUser = function (userId, data, role) {
  data.pathname = '/inventory/' + userId
  return data
}
