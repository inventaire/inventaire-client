module.exports = (body)->
  url = app.API.entities.create
  _.preq.post url, body
  .catch _.ErrorRethrow('inv_data post err')
