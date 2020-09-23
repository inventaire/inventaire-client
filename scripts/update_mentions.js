#!/usr/bin/env nodeimport CONFIG from 'config';
// Avoid to use server-side modules, as it makes executing this script
// depend on the server side repository having run 'npm install'
// which might not be the case. Ex: client-only development environment
import { omit } from 'lodash'

import { green, red } from 'chalk'
import fs from 'fs'
import { promisify } from 'util'

const __ = CONFIG.universalPath
const readFile = promisify(fs.readFile)
const writeFile = promisify(fs.writeFile)

const convertMarkdown = require('./lib/convert_markdown')

const { parse: papaparse } = require('papaparse')

const csvFile = __.path('client', 'scripts/assets/mentions.csv')
const jsonFile = __.path('client', 'public/json/mentions.json')

const cleanAttributes = function (obj) {
  for (const k in obj) {
    const v = obj[k]
    if (v === '') { delete obj[k] }
  }

  return obj
}

const mentions = {}

readFile(csvFile, { encoding: 'utf-8' })
.then(file => {
  const { data } = papaparse(file, { header: true })
  data
  .map(cleanAttributes)
  .filter(el => el.type != null)
  .forEach(el => {
    let { type, lang } = el
    // convert type to plural form
    type += 's'
    el.text = convertMarkdown(el.text)
    if (!mentions[type]) { mentions[type] = {} }
    if (!mentions[type][lang]) { mentions[type][lang] = [] }
    return mentions[type][lang].push(omit(el, [ 'type' ]))
  })

  console.log('mentions', mentions)

  const updatedFile = JSON.stringify(mentions)

  return writeFile(jsonFile, updatedFile)
  .then(() => console.log(green('done!')))
  .catch(console.error.bind(console, red('build mentions')))
})
