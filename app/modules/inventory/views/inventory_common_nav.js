import SectionList from './inventory_section_list'

export default Marionette.View.extend({
  regions: {
    usersList: '#usersList',
    groupsList: '#groupsList'
  },

  showList (regionName, collection) {
    this.showChildView(regionName, new SectionList({ collection }))
  }
})
