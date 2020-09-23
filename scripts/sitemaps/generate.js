#!/usr/bin/env nodeimport generateSitemaps from './generate_sitemaps';
/* eslint-disable
    import/no-duplicates,
    no-undef,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
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
