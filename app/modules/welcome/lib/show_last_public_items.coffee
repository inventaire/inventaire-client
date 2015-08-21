module.exports = (region)->
  _.preq.get app.API.items.lastPublicItems
  .catch _.preq.catch404
  .then displayPublicItems.bind(null, region)

displayPublicItems = (region, res)->
  unless res?.items?.length > 0
    throw new Error 'no public items'

  app.users.public.add res.users

  items = new app.Collection.Items
  items.add res.items

  region.show new app.View.Items.List
    collection: items