/* eslint-disable
    no-undef,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
let tabs

export default tabs = {
  search: {
    icon: 'search'
  },
  scan: {
    icon: 'barcode',
    wait: window.waitForDeviceDetection
  },
  import: {
    icon: 'database'
  }
}

const buildTabData = (tabName, tabData) => _.extend(tabData, {
  id: `${tabName}Tab`,
  href: `/add/${tabName}`,
  label: tabName,
  title: `title_add_layout_${tabName}`
}
)

for (const k in tabs) {
  const v = tabs[k]
  tabs[k] = buildTabData(k, v)
}
