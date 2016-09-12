#!/usr/bin/env coffee

generateSitemaps = require './generate_sitemaps'
generateIndex = require './generate_index'
{ rmFiles, gzipFiles, generateMainSitemap } = require './files_commands'
{ red } = require 'chalk'

rmFiles()

generateMainSitemap()

generateSitemaps()
.then generateMainSitemap
.then generateIndex
.then gzipFiles
.catch (err)-> console.log red('global err'), err.stack
