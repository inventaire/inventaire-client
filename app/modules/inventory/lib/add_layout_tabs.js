let tabs;

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
};

const buildTabData = (tabName, tabData) => _.extend(tabData, {
  id: `${tabName}Tab`,
  href: `/add/${tabName}`,
  label: tabName,
  title: `title_add_layout_${tabName}`
}
);

for (let k in tabs) {
  const v = tabs[k];
  tabs[k] = buildTabData(k, v);
}
