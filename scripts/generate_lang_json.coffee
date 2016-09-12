#!/usr/bin/env coffee

# HOW TO
# From time to time, you can replace src/fullkey/en by {}
# and browse all the website to regenerate an updated list of the fullkeys

unless /client$/.test process.cwd()
  throw new Error 'this script should be run from the /client/ folder'

{ grey, red } = require 'chalk'

console.time grey('total')
Promise = require './lib/bluebird'
{ universalPath } = require 'config'
args = process.argv.slice(2)
langs = universalPath.require('i18nSrc', './lib/validate_lang')(args)

extendLangWithDefault = require './lib/i18n/extend_lang_with_default'
createDirs = require './lib/i18n/create_dirs'

console.time grey('generate')

createDirs()
.then -> Promise.all langs.map(extendLangWithDefault)
.then ->
  console.timeEnd grey('generate')
  console.timeEnd grey('total')
.catch (err)-> console.log red('global err'), err.stack
