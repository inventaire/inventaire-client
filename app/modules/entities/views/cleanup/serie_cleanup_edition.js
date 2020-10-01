import WorkPicker from './work_picker'
import forms_ from 'modules/general/lib/forms'
import error_ from 'lib/error'

export default WorkPicker.extend({
  tagName: 'li',
  className: 'serie-cleanup-edition',
  template: require('./templates/serie_cleanup_edition'),

  initialize () {
    WorkPicker.prototype.initialize.call(this)
    this.editionLang = this.model.get('lang')
    this.workUri = this.model.get('claims.wdt:P629.0')
    return this.getWorksLabel()
  },

  serializeData () {
    return _.extend(this.model.toJSON(), {
      workLabel: this.workLabel,
      worksList: this._showWorkPicker ? this.getWorksList() : undefined,
      workPicker: {
        buttonIcon: 'arrows',
        buttonLabel: "change edition's work",
        validateLabel: 'validate'
      }
    })
  },

  events: _.extend({}, WorkPicker.prototype.events,
    { 'click .copyWorkLabel': 'copyWorkLabel' }),

  onWorkSelected (newWork) {
    const uri = newWork.get('uri')
    if (uri === this.workUri) { return }

    const edition = this.model
    const currentWorkEditions = edition.collection

    const rollback = function (err) {
      currentWorkEditions.add(edition)
      newWork.editions.remove(edition)
      throw err
    }

    return edition.setPropertyValue('wdt:P629', this.workUri, uri)
    .then(() => {
      // Moving the edition after the property is set is required to make sure
      // that the new edition view is initialized with the right work model and thus
      // with the right workLabel
      currentWorkEditions.remove(edition)
      return newWork.editions.add(edition)
    }).catch(rollback)
  },

  getWorksLabel () {
    if (this.editionLang == null) { return }

    return this.model.waitForWorks
    .then(works => {
      if (works.length !== 1) { return }
      const work = works[0]
      const workLabel = work.get(`labels.${this.editionLang}`)
      if ((workLabel != null) && (workLabel !== this.model.get('label'))) {
        this.workLabel = workLabel
        return this.lazyRender()
      }
    })
  },

  copyWorkLabel () {
    if (this.workLabel == null) { return }
    const currentTitle = this.model.get('claims.wdt:P1476.0')

    this.model.setPropertyValue('wdt:P1476', currentTitle, this.workLabel)
    .catch(error_.Complete('.actions', false))
    .catch(forms_.catchAlert.bind(null, this))

    this.model.setLabelFromTitle()
    this.workLabel = null
    return this.lazyRender()
  }
})
