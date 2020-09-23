import UserProfile from './user_profile'
import GroupProfile from './group_profile'
import SectionList from './inventory_section_list'
import screen_ from 'lib/screen'

export default Marionette.LayoutView.extend({
  regions: {
    usersList: '#usersList',
    groupsList: '#groupsList'
  },

  showList (region, collection) { return region.show(new SectionList({ collection })) }
})
