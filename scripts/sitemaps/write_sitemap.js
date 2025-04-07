import fs from 'node:fs'
import { promisify } from 'node:util'
import { grey, red, green } from 'tiny-chalk'

const writeFile = promisify(fs.writeFile)

export default function (path, content) {
  console.log(grey('writting sitemap'), path)
  return writeFile(path, content, err => {
    if (err != null) {
      return console.log(red('err'), err)
    } else {
      return console.log(green('done!'))
    }
  })
}
