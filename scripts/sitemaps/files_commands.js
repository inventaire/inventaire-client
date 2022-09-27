import { folderPath } from './config.js'
import { exec } from 'child_process'
import chalk from 'tiny-chalk'
import fs from 'fs'

const { grey, green } = chalk
const cp = (orignal, copy) => fs.createReadStream(orignal).pipe(fs.createWriteStream(copy))

const { stderr } = process

export function rmFiles () {
  if (folderPath.trim() === '') throw new Error('missing folderPath')
  exec(`rm -f ./${folderPath}/*`).stderr.pipe(stderr)
  return console.log(grey('removed old files'))
}

export function generateMainSitemap () {
  cp('scripts/sitemaps/main.xml', `./${folderPath}/main.xml`)
  return console.log(green('copied main.xml'))
}

export function mkdirp () {
  fs.mkdirSync(`./${folderPath}`, { recursive: true })
  return console.log(grey('created directory'))
}
