import { isOpenedOutside } from 'lib/utils'
import error_ from 'lib/error'
import forms_ from 'modules/general/lib/forms'

export default {
  itemShow (e) {
    if (!isOpenedOutside(e)) {
      app.execute('show:item', this.model)
    }
  },

  showUser (e) {
    if (!isOpenedOutside(e)) {
      app.execute('show:user', this.model.user)
      // Required to close the ItemShowLayout modal if one was open
      app.execute('modal:close')
    }
  },

  showTransaction (e) {
    if (!isOpenedOutside(e)) {
      const transac = app.request('get:transaction:ongoing:byItemId', this.model.id)
      app.execute('show:transaction', transac.id)
      // Required to close the ItemShowLayout modal if one was open
      app.execute('modal:close')
    }
  },

  updateTransaction (e) {
    this.updateItem('transaction', e.target.id)
  },

  updateListing (e) {
    this.updateItem('listing', e.target.id)
  },

  updateItem (attribute, value) {
    if ((attribute == null) || (value == null)) {
      return error_.reject('invalid item update', arguments)
    }

    return app.request('items:update', {
      items: [ this.model ],
      attribute,
      value
    })
    .catch(err => {
      err.selector = this.alertBoxTarget
      // Let the time to the view to re-render after the model rolled back
      this.setTimeout(forms_.catchAlert.bind(null, this, err), 500)
    })
  },

  itemDestroy () {
    const afterDestroy = this.afterDestroy?.bind(this) || (() => console.log('item deleted'))
    const itemDestroyBack = this.itemDestroyBack?.bind(this)
    return app.request('items:delete', {
      items: [ this.model ],
      next: afterDestroy,
      back: itemDestroyBack
    })
  }
}
