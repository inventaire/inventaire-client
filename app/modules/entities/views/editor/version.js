import versionTemplate from './templates/version.hbs'
import preq from '#lib/preq'
import forms_ from '#general/lib/forms'
import { isOpenedOutside } from '#lib/utils'
import AlertBox from '#behaviors/alert_box'

export default Marionette.View.extend({
  className: 'version',
  template: versionTemplate,

  behaviors: {
    AlertBox,
  },

  serializeData () { return this.model.serializeData() },

  modelEvents: {
    grab: 'lazyRender'
  },

  events: {
    'click .revert': 'revert',
    'click .showUser': 'showUser',
    'click .showUserContributions': 'showUserContributions',
  },

  revert () {
    const patchId = this.model.get('_id')
    preq.put(app.API.entities.revertEdit, { patch: patchId })
    .then(() => {
      app.execute('show:entity:history', this.model.entity.get('uri'))
    })
    .catch(forms_.catchAlert.bind(null, this))
  },

  showUser (e) {
    if (!isOpenedOutside(e)) app.execute('show:user', this.model.user)
  },

  showUserContributions (e) {
    if (!isOpenedOutside(e)) app.execute('show:user:contributions', this.model.user)
  }
})
