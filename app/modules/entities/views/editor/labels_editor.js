import EditorCommons from './editor_commons'
import getBestLangValue from 'modules/entities/lib/get_best_lang_value'
import forms_ from 'modules/general/lib/forms'
import getLangsData from 'modules/entities/lib/editor/get_langs_data'
import TitleTip from './lib/title_tip'

const {
  initWorkLabelsTip,
  tipOnKeyup,
  tipOnRender
} = TitleTip

export default EditorCommons.extend({
  template: require('./templates/labels_editor'),
  mainClassName: 'labels-editor',
  initialize () {
    ({ creating: this.creating } = this.model);
    ({ lang: this.lang } = app.user)
    this.editMode = !!this.creating
    return initWorkLabelsTip.call(this, this.model)
  },

  behaviors: {
    AlertBox: {}
  },

  ui: {
    input: 'input',
    langSelector: '.langSelector',
    tip: '.tip'
  },

  serializeData () {
    const { value, lang } = this.getValue()
    return {
      editMode: this.editMode,
      value,
      disableDelete: true,
      langs: getLangsData(lang, this.model.get('labels'))
    }
  },

  getValue () {
    if (this.requestedLang) {
      const value = this.model.get('labels')[this.requestedLang]
      return { value, lang: this.requestedLang }
    } else {
      return getBestLangValue(this.lang, null, this.model.get('labels'))
    }
  },

  modelEvents: {
    'change:labels': 'lazyRender'
  },

  onRender () {
    this.selectIfInEditMode()
    return tipOnRender.call(this)
  },

  select () { this.ui.input.select() },

  events: {
    'click .edit, .label-value': 'showEditMode',
    'click .save': 'save',
    'click .cancel': 'hideEditMode',
    'keyup input': 'onKeyupCustom',
    'change .langSelector': 'changeLabelLang'
  },

  changeLabelLang (e) {
    this.requestedLang = e.currentTarget.value

    if (this.model.get('labels')[this.requestedLang] != null) {
      if (this.editMode) { this.editMode = false }
    } else {
      this.editMode = true
    }

    this.lazyRender()
  },

  save () {
    const lang = this.ui.langSelector.val()
    const value = this.ui.input.val()

    if (!_.isNonEmptyString(value)) {
      return forms_.bundleAlert(this, "this value can't be empty")
    }

    this.editMode = false

    if (value === this.getValue()) {
      this.lazyRender()
    } else {
      // re-render will be triggered by change:labels event listener
      return this.model.setLabel(lang, value)
      .then(this.lazyRender.bind(this))
      .catch(err => {
        // Bring back the edit mode
        this.editMode = true
        this.lazyRender()
        // Wait for the view to have re-rendered to show the alert
        this.setTimeout(forms_.catchAlert.bind(null, this, err), 400)
      })
    }
  },

  onKeyupCustom (e) {
    this.onKeyUp(e)
    return tipOnKeyup.call(this, e)
  }
})
