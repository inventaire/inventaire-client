flo = require 'fb-flo'
fs = require 'fs'
path = require 'path'

dir = path.resolve __dirname, '../public'

params =
  port: 8888
  dir: dir
  glob: [
    '**/*.js'
    '**/*.css'
  ]

update = (window, resourceURL)-> console.log('flo update!!!')

buildUrl = (filepath)->

buildConfig = (filepath)->
  console.log '--'
  console.log 'filepath', filepath
  console.log 'resourceURL', resourceURL = '/public/' + filepath
  console.log 'contents', contents = "#{dir}/#{filepath}"
  return args =
    resourceURL: resourceURL
    contents: fs.readFileSync(contents).toString()
    update: update

resolver = (filepath, callback) -> callback buildConfig(filepath)

server = flo dir, params, resolver
server.once 'ready', -> console.log 'Ready!'
