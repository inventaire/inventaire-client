import Shelves from '../collections/shelves'
import { getShelvesByOwner } from 'modules/shelves/lib/shelves'
import ShelvesList from './shelves_list'
import shelvesSectionTemplate from './templates/shelves_section.hbs'

export default Marionette.LayoutView.extend({
  template: shelvesSectionTemplate,

  regions: {
    shelvesList: '#shelvesList'
  },

  behaviors: {
    BackupForm: {}
  },

  events: {
    'click #hideShelves': 'hideShelves',
    'click #showShelves': 'showShelves',
    'click #shelvesHeader': 'toggleShelves'
  },

  initialize () {
    this._shelvesShown = true
  },

  serializeData () {
    const inventoryUsername = this.options.username
    const currentUserName = app.user.get('username')
    if (inventoryUsername === currentUserName) {
      return { editable: true }
    }
  },

  ui: {
    shelvesList: '#shelvesList',
    hideShelves: '#hideShelves',
    showShelves: '#showShelves',
    toggleButtons: '#toggleButtons'
  },

  onShow () {
    const { username } = this.options

    this.waitForList = getUserId(username)
      .then(getShelvesByOwner)
      .then(this.ifViewIsIntact('showFromModel'))
      .catch(app.Execute('show:error'))

    this.ui.showShelves.hide()
  },

  hideShelves (e) {
    this.ui.shelvesList.addClass('wrapped')
    this.ui.showShelves.show()
    this.ui.hideShelves.hide()
    e.stopPropagation()
    this._shelvesShown = false
  },

  showShelves (e) {
    this.ui.shelvesList.removeClass('wrapped')
    this.ui.hideShelves.show()
    this.ui.showShelves.hide()
    e.stopPropagation()
    this._shelvesShown = true
  },

  toggleShelves (e) {
    if (this._shelvesShown) this.hideShelves(e)
    else this.showShelves(e)
  },

  showFromModel (docs) {
    if (docs && (docs.length < 1)) return
    this.collection = new Shelves(docs)
    this.shelvesList.show(new ShelvesList({ collection: this.collection }))
    if (this.collection.length > 5) { this.ui.toggleButtons.removeClass('hidden') }
  }
})

const getUserId = function (username) {
  if (!username) { return Promise.resolve(app.user.id) }
  return app.request('get:userId:from:username', username)
}
