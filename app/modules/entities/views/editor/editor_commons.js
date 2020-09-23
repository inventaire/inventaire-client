/* eslint-disable
    import/no-duplicates,
    no-undef,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import isLoggedIn from './lib/is_logged_in'
import getActionKey from 'lib/get_action_key'
import error_ from 'lib/error'

// This needs to be a LayoutView so that view classes extending this one can have regions
export default Marionette.LayoutView.extend({
  className () { return `value-editor-commons ${this.mainClassName}` },
  selectIfInEditMode () {
    if (this.editMode) {
      // somehow seems to need a delay
      return this.setTimeout(this.select.bind(this), 100)
    }
  },

  onKeyUp (e) {
    const key = getActionKey(e)
    switch (key) {
    case 'esc': return this.hideEditMode()
    case 'enter':
      if (e.ctrlKey) { return this.save() }
      break
    }
  },

  showEditMode (e) {
    if (!isLoggedIn()) { return }

    // Clicking on the identifier should only open wikidata in another window
    if (e?.target.className === 'identifier') { return }

    this.toggleEditMode(true)
    return this.triggerEditEvent()
  },

  triggerEditEvent () {},

  hideEditMode () {
    this.toggleEditMode(false)
    return this.resetValue()
  },

  resetValue () {},

  toggleEditMode (bool) {
    this.editMode = bool
    this.onToggleEditMode?.()
    return this.lazyRender()
  },

  // Focus an element on render
  // Requires to set a focusTarget and the corresponding UI element's name
  focusOnRender () {
    if (!this.editMode) { return }

    const focus = () => {
      const $el = this.ui[this.focusTarget]
      // Debug: run the linter to see if a view defines its ui elements twice
      if (!$el) {
        const uis = Object.keys(this.ui)
        throw error_.new("@ui[@focusTarget] isn't defined", { uis, selector: this.focusTarget })
      }
      if ($el[0].tagName === 'INPUT') {
        return $el.select()
      } else { return $el.focus() }
    }

    // Somehow required to let the time to thing to get in place
    return this.setTimeout(focus, 200)
  }
})
