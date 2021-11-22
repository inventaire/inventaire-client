import AuthorLayout from 'modules/entities/views/author_layout'
import WorkInfobox from 'modules/entities/views/work_infobox'
import currentTaskTemplate from './templates/current_task.hbs'

export default Marionette.LayoutView.extend({
  template: currentTaskTemplate,
  serializeData () {
    return _.extend(this.model.serializeData(), { showSourcesLinks: true })
  },

  regions: {
    suspect: '#suspect',
    suggestion: '#suggestion',
    otherSuggestions: '#otherSuggestions'
  },

  onShow () {
    if (this.model.get('entitiesType') === 'human') {
      this.showAuthor('suspect')
      this.showAuthor('suggestion')
    } else {
      this.showWork('suspect')
      this.showWork('suggestion')
    }
  },

  showAuthor (name) {
    this[name].show(new AuthorLayout({
      model: this.model[name],
      initialWorksListLength: 20,
      wrapWorks: true,
      noAuthorWrap: true,
      standalone: true
    }))
  },

  showWork (name) {
    this[name].show(new WorkInfobox({
      model: this.model[name]
    }))
  }
})
