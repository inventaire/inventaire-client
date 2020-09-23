export default Marionette.LayoutView.extend({
  // regions:
    // infoboxRegion
    // mergeSuggestionsRegion: '.mergeSuggestions'

  className() {
    let className = this.baseClassName || '';
    if (this.options.standalone) { className += ' standalone'; }
    return className.trim();
  },

  Infobox: require('./general_infobox'),

  initialize() {
    return ({ refresh: this.refresh, standalone: this.standalone, displayMergeSuggestions: this.displayMergeSuggestions } = this.options);
  },

  serializeData() {
    return {
      standalone: this.standalone,
      displayMergeSuggestions: this.displayMergeSuggestions
    };
  },

  onRender() {
    this.showInfobox();
    return this.showMergeSuggestions();
  },

  showInfobox() {
    const { Infobox } = this;
    return this.infoboxRegion.show(new Infobox({ model: this.model, standalone: this.standalone }));
  },

  showMergeSuggestions() {
    if (!this.displayMergeSuggestions) { return; }
    return app.execute('show:merge:suggestions', { model: this.model, region: this.mergeSuggestionsRegion });
  }});
