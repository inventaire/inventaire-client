publicPath = 'public/sitemaps'

module.exports =
  publicPath: publicPath
  folder: "./#{publicPath}"
  main: 'main.xml'
  index: 'sitemapindex.xml'
  autolists:
    authors: [ 'P106', 'Q36180' ]
    books: [ 'P31', 'Q571' ]
    genres: [ 'P31', 'Q223393' ]
    movements: [ 'P31', 'Q3326717' ]

  wdQuery: (P, Q)->
    # use the local server to cache requests to Wikidata Query
    "http://localhost:3006/api/data?api=wd-query&query=claim&pid=#{P}&qid=#{Q}"
