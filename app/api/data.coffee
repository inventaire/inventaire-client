{ public:publik } = require('./endpoint')('data')
dataQuery = _.buildPath.bind(_, publik)

module.exports =
  wikipediaExtract: (lang, title)->
    dataQuery
      api: 'wp-extract'
      lang: lang
      title: title

  isbn: (isbn)-> _.buildPath publik, { isbn }
