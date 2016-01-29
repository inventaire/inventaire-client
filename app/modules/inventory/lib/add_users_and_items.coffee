module.exports = (itemsCollection, res)->
  { items, users } = res
  unless items?.length > 0
    err = new Error 'no public items'
    err.status = 404
    throw err

  app.execute 'users:public:add', users
  itemsCollection.add items
  return