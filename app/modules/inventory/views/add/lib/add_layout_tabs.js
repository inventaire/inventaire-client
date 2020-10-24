import SearchLayout from '../search_layout'
import ScanLayout from '../scan_layout'
import ImportLayout from '../import_layout'

let tabs

export default tabs = {
  search: {
    icon: 'search',
    View: SearchLayout,
  },
  scan: {
    icon: 'barcode',
    View: ScanLayout,
    wait: window.waitForDeviceDetection,
  },
  import: {
    icon: 'database',
    View: ImportLayout,
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
