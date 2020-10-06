#!/usr/bin/env node
import lodash from 'lodash'
import chalk from 'chalk'
import fs from 'fs'
import papaparse from 'papaparse'
import { promisify } from 'util'
import convertMarkdown from './lib/convert_markdown.js'
const { green, red } = chalk
const { omit } = lodash

const readFile = promisify(fs.readFile)
const writeFile = promisify(fs.writeFile)


const csvFile = './scripts/assets/mentions.csv'
const jsonFile = './public/json/mentions.json'

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
  const { data } = papaparse.parse(file, { header: true })
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
