appRoot = require('app-root-path').path

module.exports =
  paths:
    server: '/server'
    serverLib: '/server/lib'
    client: '/client'
    scripts: '/client/scripts'
    test: '/client/test'
    app: '/client/app'
    lib: '/client/app/lib'
    shared: '/client/app/lib/shared'
    entities: '/client/app/modules/entities'
  path: (route, name)->
    path = @paths[route]
    return "#{appRoot}#{path}/#{name}"
  require: (route, name)-> require @path(route, name)