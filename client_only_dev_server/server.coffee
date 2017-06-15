#!/usr/bin/env coffee

express = require 'express'
logger = require 'morgan'
app = express()
app.use logger('combined')

https = require 'https'
fs = require 'fs'
path = require 'path'
{ green } = require 'chalk'
request = require 'request'
port = 3000
publicFolder = path.join __dirname, '../public'

app.get '/api/*', (req, res)->
  url = 'https://inventaire.io' + req.originalUrl
  console.log(green('proxying'), url)
  req.pipe(request({ url })).pipe(res)

app.get '*', (req, res)->
  { url } = req
  if url is '/' then url = '/index.html'
  url = url.replace '/public', '/'
  res.sendFile "#{publicFolder}#{url}"

app.use express.static(path.join(__dirname + '../public'))

options =
  key: fs.readFileSync "#{__dirname}/server.key"
  cert: fs.readFileSync "#{__dirname}/server.crt"

https.createServer(options, app).listen port
