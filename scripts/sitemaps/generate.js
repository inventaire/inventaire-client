#!/usr/bin/env node
import chalk from 'tiny-chalk'
import { rmFiles, generateMainSitemap, mkdirp } from './files_commands.js'
import { generateIndex } from './generate_index.js'
import { generateSitemaps } from './generate_sitemaps.js'

rmFiles()
mkdirp()
generateMainSitemap()

generateSitemaps()
.then(generateIndex)
.catch(err => console.log(chalk.red('global err'), err.stack))
