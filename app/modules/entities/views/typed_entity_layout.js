import GeneralInfobox from './general_infobox'
export default Marionette.LayoutView.extend({
  // regions:
  //   infoboxRegion
  //   mergeHomonymsRegion: '.mergeHomonyms'

  className () {
    let className = this.baseClassName || ''
    if (this.options.standalone) className += ' standalone'
    return className.trim()
  },

  Infobox: GeneralInfobox,

  initialize () {
    ({ refresh: this.refresh, standalone: this.standalone, displayMergeSuggestions: this.displayMergeSuggestions } = this.options)
  },

  serializeData () {
    return {
      standalone: this.standalone,
      displayMergeSuggestions: this.displayMergeSuggestions
    }
  },

  onRender () {
    this.showInfobox()
    this.showHomonyms()
  },

  showInfobox () {
    const { Infobox } = this
    this.infoboxRegion.show(new Infobox({
      model: this.model,
      standalone: this.standalone
    }))
  },

  showHomonyms () {
    if (!this.displayMergeSuggestions) return
    app.execute('show:homonyms', {
      model: this.model,
      region: this.mergeHomonymsRegion
    })
  }
})
