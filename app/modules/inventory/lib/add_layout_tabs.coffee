module.exports = tabs =
  search:
    icon: 'search'
  scan:
    icon: 'barcode'
  import:
    icon: 'database'

buildTabData = (tabName, tabData)->
  _.extend tabData,
    id: "#{tabName}Tab"
    href: "/add/#{tabName}"
    label: tabName
    title: "title_add_layout_#{tabName}"

for k, v of tabs
  tabs[k] = buildTabData k, v
