{ public:publik } = require('./endpoint')('data')
dataQuery = _.buildPath.bind(_, publik)

wdQuery = (params)->
  params.api = 'wd-query'
  dataQuery params

formatQid = (qid)-> qid.replace 'wd:', ''
formatPid = (pid)-> pid.replace 'wdt:', ''

module.exports =
  claim: (pid, qid, refresh)->
    wdQuery
      query: 'claim'
      pid: formatPid pid
      qid: formatQid qid
      refresh: refresh

  authorWorks: (qid, refresh)->
    wdQuery
      query: 'author-works'
      qid: formatQid qid
      refresh: refresh

  commonsThumb: (file, width)->
    dataQuery
      api: 'commons-thumb'
      file: file
      width: width

  wikipediaExtract: (lang, title)->
    dataQuery
      api: 'wp-extract'
      lang: lang
      title: title

  openLibraryCover: (openLibraryId, type='book')->
    dataQuery
      api: 'openlibrary-cover'
      id: openLibraryId
      type: type

  enWpImage: (enWpTitle)->
    dataQuery
      api: 'en-wikipedia-image'
      title: enWpTitle

  isbn: (isbn)-> _.buildPath publik, { isbn }
