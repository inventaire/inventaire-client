allTabs = require('../lib/network_tabs').tabsData.all

updateRoute = (base, key, query)->
  { path, title } = allTabs[key]
  base = _.I18n base
  tabTitle = _.I18n title
  app.navigate _.buildPath(path, { q: query }),
    metadata: { title: "#{query} - #{tabTitle} - #{base}" }

module.exports = (base, key)-> _.debounce updateRoute.bind(null, base, key), 300
