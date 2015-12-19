#!/usr/bin/env coffee

require 'colors'
generateSitemaps = require './generate_sitemaps'
generateIndex = require './generate_index'
{ rmFiles, gzipFiles, generateMainSitemap } = require './files_commands'

rmFiles()

generateMainSitemap()

generateSitemaps()
.then generateMainSitemap
.then generateIndex
.then gzipFiles
.catch (err)-> console.log 'global err'.red, err.stack

