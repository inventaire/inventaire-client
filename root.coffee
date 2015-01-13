appRoot = require('app-root-path').path

module.exports =
  paths:
    client: '/client'
    scripts: '/client/scripts'
    app: '/client/app'
    lib: '/client/app/lib'
    shared: '/client/app/lib/shared'
  path: (route, name)->
    path = @paths[route]
    return "#{appRoot}#{path}/#{name}"
  require: (route, name)-> require @path(route, name)