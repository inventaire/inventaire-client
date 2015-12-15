appRoot = __dirname.replace '/client', ''

global.requireProxy = requireProxy = (path)->
  # ex: converts 'lib/wikidata' into #{appRoute}/client/app/lib/wikidata
  if /^[a-z]+\/[a-z_]+/.test path
    require "#{appRoot}/client/app/#{path}"
  else
    require path

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