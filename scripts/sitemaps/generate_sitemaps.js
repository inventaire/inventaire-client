import fetch from 'node-fetch'
import writeSitemap from './write_sitemap.js'
import { folderPath } from './config.js'
import chalk from 'tiny-chalk'
import wdk from 'wikidata-sdk'
import queries from './queries.js'
import wrapUrls from './wrap_urls.js'

const { green } = chalk

export function generateSitemaps () {
  const queriesNames = Object.keys(queries)

  // Generating sequentially to prevent overpassing Wikidata Query Service parallel request quota
  const generateFilesSequentially = function () {
    const nextQueryName = queriesNames.shift()
    if (nextQueryName == null) return console.log(green('done'))
    return generateFilesFromQuery(nextQueryName)
    .then(generateFilesSequentially)
  }

  return generateFilesSequentially()
}

const generateFilesFromQuery = async name => {
  console.log(green(`${name} query`), queries[name])
  const url = queries[name]
  const results = await fetch(url, {
    headers: {
      'user-agent': 'inventaire-client (https://github.com/inventaire/inventaire-client)'
    }
  })
  .then(res => res.json())

  try {
    const items = await wdk.simplifySparqlResults(results)
    return getParts(name, items).map(generateFile)
  } catch (err) {
    console.error('failed to parse SPARQL results', results)
    throw err
  }
}

const uniq = array => Array.from(new Set(array))

const getParts = (name, items) => {
  const parts = []
  let index = 0

  items = uniq(items)

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

const generateFile = part => {
  const { name, items, index } = part
  const path = getFilePath(name, index)
  return writeSitemap(path, wrapUrls(items.map(buildUrlNode)))
}

const buildUrlNode = id => `<url><loc>https://inventaire.io/entity/wd:${id}</loc></url>`

const getFilePath = (name, index) => `./${folderPath}/${name}-${index}.xml`
