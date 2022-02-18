#!/usr/bin/env node
import chalk from 'tiny-chalk'
import fs from 'fs'
import path from 'path'
import papaparse from 'papaparse'
import { promisify } from 'util'
import convertMarkdown from './lib/convert_markdown.js'

const { green, red } = chalk

const readFile = promisify(fs.readFile)
const writeFile = promisify(fs.writeFile)

const csvFile = path.resolve(process.cwd(), './scripts/assets/mentions.csv')
const jsonFile = path.resolve(process.cwd(), './public/json/mentions.json')

const cleanAttributes = function (obj) {
  Object.keys(obj).forEach(key => {
    if (obj[key] === '') delete obj[key]
  })
  return obj
}

const mentions = {}

readFile(csvFile, { encoding: 'utf-8' })
.then(async file => {
  const { data } = papaparse.parse(file, { header: true })
  data
  .map(cleanAttributes)
  .filter(el => el.type != null)
  .forEach(el => {
    let { type, lang } = el
    // convert type to plural form
    type += 's'
    el.text = convertMarkdown(el.text)
    mentions[type] = mentions[type] || {}
    mentions[type][lang] = mentions[type][lang] || []
    delete el.type
    return mentions[type][lang].push(el)
  })

  const updatedFile = JSON.stringify(mentions)

  await writeFile(jsonFile, updatedFile)
  console.log(green('done updating mentions'))
})
.catch(console.error.bind(console, red('build mentions')))
