import { checkVideoInput } from '#lib/has_video_input.ts'
import ScanLayout from '../scan_layout.ts'
import SearchLayout from '../search_layout.ts'

let tabs

export default tabs = {
  search: {
    icon: 'search',
    View: SearchLayout,
  },
  scan: {
    icon: 'barcode',
    View: ScanLayout,
    wait: checkVideoInput(),
  },
  import: {
    icon: 'database',
  },
}

const buildTabData = (tabName, tabData) => Object.assign(tabData, {
  id: `${tabName}Tab`,
  href: `/add/${tabName}`,
  label: tabName,
  title: `title_add_layout_${tabName}`,
})

for (const k in tabs) {
  const v = tabs[k]
  tabs[k] = buildTabData(k, v)
}
