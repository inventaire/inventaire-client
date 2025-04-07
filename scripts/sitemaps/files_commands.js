import { exec } from 'node:child_process'
import fs from 'node:fs'
import { grey, green } from 'tiny-chalk'
import { folderPath } from './config.js'

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
