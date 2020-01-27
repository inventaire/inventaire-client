allTabs = require('../lib/network_tabs').tabsData.all
{ buildPath } = require 'lib/location'

updateRoute = (base, key, query)->
  { path, title } = allTabs[key]
  base = _.I18n base
  tabTitle = _.I18n title
  if query? and query isnt ''
    app.navigate buildPath(path, { q: query }),
      metadata: { title: "#{query} - #{tabTitle} - #{base}" }
  else
    app.navigate path,
      metadata: { title: "#{tabTitle} - #{base}" }

module.exports = (base, key)-> _.debounce updateRoute.bind(null, base, key), 300
