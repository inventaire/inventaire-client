import EditorCommons from './editor_commons'
import forms_ from 'modules/general/lib/forms'
import properties from 'modules/entities/lib/properties'

// Methods that can't be on editor_commons because ./labels_editor is structured differently:
// while property values are having an ad-hoc model created, labels just use their entity's
// label
export default EditorCommons.extend({
  behaviors: {
    AlertBox: {}
  },

  initEditModeState () {
    // If the value is null, start in edit mode
    this.editMode = (this.model.get('value') == null)
  },

  serializeData () {
    const attrs = this.model.toJSON()
    attrs.editMode = this.editMode
    const { property, value } = attrs
    if ((value != null) && (properties[property].editorType === 'image')) {
      attrs.imageUrl = `/img/entities/${value}`
    }
    return attrs
  },

  resetValue () {
    // In case an empty value was created to allow creating a new claim
    // but the action was cancelled
    // Known cases; 'delete', 'cancel' with no previous value saved
    if ((this.model.get('value') == null)) { return this.model.destroy() }
  },

  delete () {
    // Do not ask for confirmation when there was no previously existing statement
    if (this.model.get('value') === null) { return this._save(null) }

    app.execute('ask:confirmation', {
      confirmationText: _.i18n('Are you sure you want to delete this statement?'),
      action: () => this._save(null)
    })
  },

  // To be define on the children and call @_save
  // save: ->

  _save (newValue) {
    return this._bareSave(newValue)
    .catch(this._catchAlert.bind(this))
  },

  _bareSave (newValue) {
    const uri = this.model.entity.get('uri')

    const promise = this.model.saveValue(newValue)
      .catch(enrichError(uri))

    // Should be triggered after @model.saveValue so that a defined value
    // doesn't appear null for @hideEditMode
    this.hideEditMode()

    return promise
    .catch(err => {
      // Re-display the edit mode to show the alert
      this.showEditMode()
      return Promise.resolve()
      // Throw the error after the view lazy re-rendered
      .delay(250)
      .then(() => { throw err })
    })
  },

  _catchAlert (err) {
    // Making sure that we are in edit mode as it might have re-rendered
    // already before the error came back from the server
    this.showEditMode()

    const alert = () => forms_.catchAlert(this, err)
    // Let the time to the changes and rollbacks to trigger lazy re-render
    // before trying to show the alert message
    this.setTimeout(alert, 500)
  }
})

const enrichError = uri => function (err) {
  if (err.responseJSON?.status_verbose === 'this property value is already used') {
    const { entity: duplicateUri } = err.responseJSON.context
    reportPossibleDuplicate(uri, duplicateUri)
    formatDuplicateErr(err, uri, duplicateUri)
  }

  throw err
}

const reportPossibleDuplicate = (uri, duplicateUri) => app.request('post:feedback', {
  subject: `[Possible duplicate] ${uri} / ${duplicateUri}`,
  uris: [ uri, duplicateUri ]
})

const formatDuplicateErr = function (err, uri, duplicateUri) {
  const alreadyExist = _.i18n('this value is already used')
  const link = `<a href='/entity/${duplicateUri}' class='showEntity'>${duplicateUri}</a>`
  const reported = _.i18n('the issue was reported')
  err.responseJSON.status_verbose = `${alreadyExist}: ${link} (${reported})`
  err.i18n = false
}
