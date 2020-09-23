/* eslint-disable
    import/no-duplicates,
    no-undef,
    no-unused-vars,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
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
