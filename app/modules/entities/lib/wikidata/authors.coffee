wd_ = require 'lib/wikidata'

wdAuthors_ = {}

wdAuthors_.fetchAuthorsBooks = (authorModel, limit)->
  wdAuthors_.fetchAuthorsBooksIds(authorModel)
  .then -> wdAuthors_.fetchAuthorsBooksEntities(authorModel)
  .catch (err)->  _.log err.split('\n'), 'wdAuthors_.fetchAuthorsBooks err?'

wdAuthors_.fetchAuthorsBooksIds = (authorModel)->
  if authorModel.get('reverseClaims')?.P50?
    _.preq.resolve()
  else
    numericId = authorModel.id.replace(/^Q/,'')
    # TODO: also fetch aliased Properties, not only P50
    _.preq.get wd_.API.wmflabs.claim(50, numericId)
    .then (res)->
      if res?.items?
        booksIds = wd_.normalizeIds res.items
        _.log booksIds, 'booksIds'
        authorModel.set 'reverseClaims.P50', booksIds
        # almost useless to save yet as cached Author
        # will be overriden by the unformatted data
        # packaged in the entity search process
        authorModel.save()
    .catch (err)-> _.log err, 'fetchAuthorsBooksIds err'

wdAuthors_.fetchAuthorsBooksEntities = (authorModel)->
  authorsBooks = authorModel.get 'reverseClaims.P50'
  _.log authorsBooks, 'authorsBooks?'
  if authorsBooks?.length > 0
    return app.request('get:entities:models', 'wd', authorsBooks)
    # type = 'book'
    # return Entities.tmp.wd_.fetchModels authorsBooks, type
  else _.preq.resolve()

module.exports = wdAuthors_
