import writeSitemap from './write_sitemap.js'
import fs from 'fs'
import { folderPath, index } from './config.js'
const exclude = [ index ]

export function generateIndex () {
  const path = `./${folderPath}/${index}`
  return writeSitemap(path, generate())
}

const generate = () => wrapIndex(getList().map(buildSitemapNode))

const getList = () => fs.readdirSync(`./${folderPath}`).filter(file => !exclude.includes(file))

const buildSitemapNode = function (filename) {
  const url = `https://inventaire.io/${folderPath}/${filename}`
  return `<sitemap><loc>${url}</loc></sitemap>`
}

const wrapIndex = function (sitemapNodes) {
  const text = sitemapNodes.join('')
  return `<?xml version="1.0" encoding="UTF-8"?>
<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${text}
</sitemapindex>`
}
