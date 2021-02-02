import SectionList from './inventory_section_list'

export default Marionette.LayoutView.extend({
  showList (region, collection) {
    if (this.isIntact()) region.show(new SectionList({ collection }))
  }
})
