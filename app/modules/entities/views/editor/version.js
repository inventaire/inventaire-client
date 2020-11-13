import versionTemplate from './templates/version.hbs'
import preq from 'lib/preq'
import forms_ from 'modules/general/lib/forms'

export default Marionette.ItemView.extend({
  className: 'version',
  template: versionTemplate,

  behaviors: {
    AlertBox: {}
  },

  serializeData () { return this.model.serializeData() },

  modelEvents: {
    grab: 'lazyRender'
  },

  events: {
    'click .revert': 'revert',
  },

  revert () {
    const patchId = this.model.get('_id')
    preq.put(app.API.entities.revertEdit, { patch: patchId })
    .then(() => {
      app.execute('show:entity:history', this.model.entity.get('uri'))
    })
    .catch(forms_.catchAlert.bind(null, this))
  }
})
