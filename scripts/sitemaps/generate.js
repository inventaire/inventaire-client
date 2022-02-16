#!/usr/bin/env node
import chalk from 'tiny-chalk'
import generateSitemaps from './generate_sitemaps.js'
import generateIndex from './generate_index.js'
import FilesCommands from './files_commands.js'

const {
  rmFiles,
  generateMainSitemap
} = FilesCommands

rmFiles()

generateMainSitemap()

generateSitemaps()
.then(generateIndex)
.catch(err => console.log(chalk.red('global err'), err.stack))
