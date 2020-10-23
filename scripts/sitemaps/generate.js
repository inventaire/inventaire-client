#!/usr/bin/env node
import chalk from 'tiny-chalk'
import generateSitemaps from './generate_sitemaps'
import generateIndex from './generate_index'
import FilesCommands from './files_commands'

const {
  rmFiles,
  generateMainSitemap
} = FilesCommands

rmFiles()

generateMainSitemap()

generateSitemaps()
.then(generateIndex)
.catch(err => console.log(chalk.red('global err'), err.stack))
