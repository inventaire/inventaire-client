import GeneralInfobox from './general_infobox'
export default Marionette.LayoutView.extend({
  // regions:
  //   infoboxRegion
  //   mergeSuggestionsRegion: '.mergeSuggestions'

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
    this.showMergeSuggestions()
  },

  showInfobox () {
    const { Infobox } = this
    this.infoboxRegion.show(new Infobox({
      model: this.model,
      standalone: this.standalone
    }))
  },

  showMergeSuggestions () {
    if (!this.displayMergeSuggestions) return
    app.execute('show:merge:suggestions', {
      model: this.model,
      region: this.mergeSuggestionsRegion
    })
  }
})
