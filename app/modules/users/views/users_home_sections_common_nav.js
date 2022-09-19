import SectionList from '#users/views/users_home_section_list.js'

export default Marionette.View.extend({
  regions: {
    usersList: '#usersList',
    groupsList: '#groupsList'
  },

  showList (regionName, collection) {
    this.showChildView(regionName, new SectionList({ collection }))
  }
})
