#!/usr/bin/env node
import generateSitemaps from './generate_sitemaps'
import generateIndex from './generate_index'
import FilesCommands from './files_commands'

import { red } from 'chalk'

const {
  rmFiles,
  gzipFiles,
  generateMainSitemap
} = FilesCommands

rmFiles()

generateMainSitemap()

generateSitemaps()
.then(generateIndex)
.then(gzipFiles)
.catch(err => console.log(red('global err'), err.stack))
