export default function(userId, uris){
  if (uris.length === 0) { return Promise.resolve({}); }

  // Split in batches for cases where there might be too many uris
  // to put in a URL querystring without risking to reach URL character limit
  // Known case: when /add/import gets to import very large collections
  // The alternative would be to convert the endpoint to a POST verb to pass those uris in a body
  const urisBatches = _.chunk(_.uniq(uris).sort(), 50);

  const responses = [];
  const counts = {};
  var getBatchesSequentially = function() {
    const nextBatch = urisBatches.pop();
    if (nextBatch == null) { return counts; }
    return getEntityItemsCountBatch(userId, nextBatch)
    .then(res => countEntitiesItems(counts, res))
    .then(getBatchesSequentially);
  };

  return getBatchesSequentially();
};

var getEntityItemsCountBatch = (userId, uris) => _.preq.get(app.API.items.byUserAndEntities(userId, uris));

var countEntitiesItems = function(counts, res){
  for (let item of res.items) {
    const uri = item.entity;
    if (counts[uri] == null) { counts[uri] = 0; }
    counts[uri]++;
  }
};
