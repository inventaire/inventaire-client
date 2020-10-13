import SearchView from '../search'
import ScanView from '../scan'
import ImportView from '../import'

let tabs

export default tabs = {
  search: {
    icon: 'search',
    View: SearchView,
  },
  scan: {
    icon: 'barcode',
    View: ScanView,
    wait: window.waitForDeviceDetection,
  },
  import: {
    icon: 'database',
    View: ImportView,
  }
}

const buildTabData = (tabName, tabData) => _.extend(tabData, {
  id: `${tabName}Tab`,
  href: `/add/${tabName}`,
  label: tabName,
  title: `title_add_layout_${tabName}`
})

for (const k in tabs) {
  const v = tabs[k]
  tabs[k] = buildTabData(k, v)
}
