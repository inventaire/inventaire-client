import breq from 'bluereq'
import _ from 'lodash'
import writeSitemap from './write_sitemap'
import { folder } from './config'
import { green } from 'chalk'
import wdk from 'wikidata-sdk'
import queries from './queries'

export default function () {
  const queriesNames = Object.keys(queries)

  // Generating sequentially to prevent overpassing Wikidata Query Service parallel request quota
  const generateFilesSequentially = function () {
    const nextQueryName = queriesNames.shift()
    if (nextQueryName == null) { return console.log(green('done')) }
    return generateFilesFromQuery(nextQueryName)
    .then(generateFilesSequentially)
  }

  return generateFilesSequentially()
}

const generateFilesFromQuery = async name => {
  console.log(green(`${name} query`), queries[name])
  const { body: results } = await breq.get({
    url: queries[name],
    headers: {
      'user-agent': 'inventaire-client (https://github.com/inventaire/inventaire-client)'
    }
  })
  try {
    const simplifiedResults = await wdk.simplifySparqlResults(results)
    return getParts(name, simplifiedResults)
    .map(generateFile)
  } catch (err) {
    console.error('failed to parse SPARQL results', results)
    throw err
  }
}

const getParts = name => function (items) {
  const parts = []
  let index = 0

  items = _.uniq(items)

  while (items.length > 0) {
    // override items
    let part;
    [ part, items ] = [ items.slice(0, 50000), items.slice(50000) ]
    index += 1
    parts.push({ name, items: part, index })
  }

  console.log(green(`got ${index} parts`))
  return parts
}

const generateFile = function (part) {
  const { name, items, index } = part
  const path = getFilePath(name, index)
  return writeSitemap(path, wrapUrls(items.map(buildUrlNode)))
}

const wrapUrls = require('./wrap_urls')

const buildUrlNode = id => `<url><loc>https://inventaire.io/entity/wd:${id}</loc></url>`

const getFilePath = (name, index) => `${folder}/${name}-${index}.xml`
