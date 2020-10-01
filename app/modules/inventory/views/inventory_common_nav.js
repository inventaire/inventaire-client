import SectionList from './inventory_section_list'

export default Marionette.LayoutView.extend({
  regions: {
    usersList: '#usersList',
    groupsList: '#groupsList'
  },

  showList (region, collection) { return region.show(new SectionList({ collection })) }
})
