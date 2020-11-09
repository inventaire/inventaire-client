/* eslint-disable
    no-unused-vars,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
let requireProxy
const appRoot = __dirname.replace('/client', '')

global.requireProxy = (requireProxy = function (path) {
  // ex: converts 'lib/wikidata' into #{appRoute}/client/app/lib/wikidata
  if (/^[a-z]+\/[a-z_]+/.test(path)) {
    return require(`${appRoot}/client/app/${path}`)
  } else {
    return require(path)
  }
})

export default {
  paths: {
    server: '/server',
    serverLib: '/server/lib',
    client: '/client',
    scripts: '/client/scripts',
    test: '/client/test',
    fixtures: '/client/test/fixtures',
    app: '/client/app',
    modules: '/client/app/modules',
    lib: '/client/app/lib',
    shared: '/client/app/lib/shared',
    entities: '/client/app/modules/entities'
  },
  path (route, name) {
    const path = this.paths[route]
    return `${appRoot}${path}/${name}`
  },
  require (route, name) { return require(this.path(route, name)) }
}
