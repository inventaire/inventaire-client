import fs from 'fs'
import { promisify } from 'util'
import chalk from 'chalk'

const writeFile = promisify(fs.writeFile)
const { grey, red, green } = chalk

export default function (path, content) {
  console.log(grey('writting sitemap'), path)
  return writeFile(path, content, (err, res) => {
    if (err != null) {
      return console.log(red('err'), err)
    } else {
      return console.log(green('done!'))
    }
  })
}
