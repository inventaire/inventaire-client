allTabs = require('../lib/network_tabs').tabsData.all

updateRoute = (path, query)->
  app.navigate _.buildPath(path, {q: query})

module.exports = (key)->
  { path } = allTabs[key]
  _.debounce updateRoute.bind(null, path), 300
