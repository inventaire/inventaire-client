module.exports =
  getAuthorBooks: (authorModel, refresh)->
    uri = authorModel.get 'uri'

    _.preq.get app.API.entities.authorWorks(uri, refresh)
    .then _.Log("author work - #{uri}")
    .get 'books'
    .map _.property('uri')
    .then (uris)-> app.request 'get:entities:models:from:uris', uris, refresh
    .then (booksModels)-> { books: booksModels }
    .catch _.ErrorRethrow('getAuthorBooks')
