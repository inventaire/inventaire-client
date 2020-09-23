export default function() {
  const [ itemId, ownerId, requesterId ] = Array.from(this.gets('item', 'owner', 'requester'));
  const { item, owner, requester } = this.get('snapshot');
  return this.set({
    'snapshot.item': formatSnapshotItem(itemId, item),
    'snapshot.owner': formatSnapshotUser(ownerId, owner, 'owner'),
    'snapshot.requester': formatSnapshotUser(requesterId, requester, 'requester')
  });
};

var formatSnapshotItem = function(itemId, data){
  data.pathname = '/items/' + itemId;
  return data;
};

var formatSnapshotUser = function(userId, data, role){
  data.pathname = '/inventory/' + userId;
  return data;
};
