import { folder } from './config'
import { exec } from 'child_process'
import chalk from 'tiny-chalk'
import fs from 'fs'

const { grey, green } = chalk
const ls = dir => console.log(fs.readdirSync(dir))
const cp = (orignal, copy) => fs.createReadStream(orignal).pipe(fs.createWriteStream(copy))

const { stderr } = process

export default {
  rmFiles () {
    if (folder.trim() === '') throw new Error('missing folder')
    exec(`rm -f ./${folder}/*`).stderr.pipe(stderr)
    return console.log(grey('removed old files'))
  },
  generateMainSitemap () {
    cp('scripts/sitemaps/main.xml', `${folder}/main.xml`)
    return console.log(green('copied main.xml'))
  },

  ls,
  cp
}
