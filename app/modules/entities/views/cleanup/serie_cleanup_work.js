import getActionKey from 'lib/get_action_key';
import getLangsData from 'modules/entities/lib/editor/get_langs_data';
import SerieCleanupAuthors from './serie_cleanup_authors';
import SerieCleanupEditions from './serie_cleanup_editions';
import WorkPicker from './work_picker';
import forms_ from 'modules/general/lib/forms';
import error_ from 'lib/error';

export default Marionette.LayoutView.extend({
  tagName: 'li',
  template: require('./templates/serie_cleanup_work'),
  className() {
    let classes = 'serie-cleanup-work';
    if (this.model.get('isPlaceholder')) { classes += ' placeholder'; }
    return classes;
  },

  regions: {
    mergeWorkPicker: '.mergeWorkPicker',
    authorsContainer: '.authorsContainer',
    editionsContainer: '.editionsContainer'
  },

  ui: {
    head: '.head',
    placeholderEditor: '.placeholderEditor',
    placeholderLabelEditor: '.placeholderEditor input',
    langSelector: '.langSelector'
  },

  behaviors: {
    AlertBox: {}
  },

  initialize() {
    ({ worksWithOrdinal: this.worksWithOrdinal, worksWithoutOrdinal: this.worksWithoutOrdinal } = this.options);
    const lazyLangSelectorUpdate = _.debounce(this.onOtherLangSelectorChange.bind(this), 500);
    this.listenTo(app.vent, 'lang:local:change', lazyLangSelectorUpdate);
    // This is required to update works ordinal selectors
    this.listenTo(app.vent, 'serie:cleanup:parts:change', this.lazyRender.bind(this));

    return ({ allAuthorsUris: this.allAuthorsUris } = this.options);
  },

  serializeData() {
    const data = this.model.toJSON();
    const localLang = app.request('lang:local:get');
    data.langs = getLangsData(localLang, this.model.get('labels'));
    if (this.options.showPossibleOrdinals) {
      const nonPlaceholdersOrdinals = this.worksWithOrdinal.getNonPlaceholdersOrdinals();
      data.possibleOrdinals = getPossibleOrdinals(nonPlaceholdersOrdinals);
    }
    return data;
  },

  onRender() {
    if (this.model.get('isPlaceholder')) {
      this.$el.attr('tabindex', 0);
      return;
    }

    this.showWorkAuthors();

    return this.model.fetchSubEntities()
    .then(this.ifViewIsIntact('showWorkEditions'));
  },

  toggleMergeWorkPicker() {
    if (this.mergeWorkPicker.currentView != null) {
      return this.mergeWorkPicker.currentView.$el.toggle();
    } else {
      return this.mergeWorkPicker.show(new WorkPicker({
        model: this.model,
        worksWithOrdinal: this.worksWithOrdinal,
        worksWithoutOrdinal: this.worksWithoutOrdinal,
        _showWorkPicker: true,
        workUri: this.model.get('uri'),
        afterMerge: this.afterMerge
      }));
    }
  },

  afterMerge(work){
    this.worksWithOrdinal.remove(this.model);
    this.worksWithoutOrdinal.remove(this.model);
    return work.editions.add(this.model.editions.models);
  },

  showWorkAuthors() {
    const { currentAuthorsUris, authorsSuggestionsUris } = this.spreadAuthors();
    return this.authorsContainer.show(new SerieCleanupAuthors({
      work: this.model,
      currentAuthorsUris,
      authorsSuggestionsUris
    }));
  },

  showWorkEditions() {
    return this.editionsContainer.show(new SerieCleanupEditions({
      collection: this.model.editions,
      worksWithOrdinal: this.worksWithOrdinal,
      worksWithoutOrdinal: this.worksWithoutOrdinal
    }));
  },

  events: {
    'change .ordinalSelector': 'updateOrdinal',
    'click .create': 'create',
    'click': 'showPlaceholderEditor',
    'keydown': 'onKeyDown',
    'change .langSelector': 'propagateLangChange',
    'click .toggleMergeWorkPicker': 'toggleMergeWorkPicker'
  },

  updateOrdinal(e){
    const { value } = e.currentTarget;
    return this.model.setPropertyValue('wdt:P1545', null, value)
    .catch(error_.Complete('.head', false))
    .catch(forms_.catchAlert.bind(null, this));
  },

  showPlaceholderEditor() {
    if (!this.model.get('isPlaceholder')) { return; }
    if (!this.ui.placeholderEditor.hasClass('hidden')) { return; }
    this.ui.head.addClass('force-hidden');
    this.ui.placeholderEditor.removeClass('hidden');
    this.$el.attr('tabindex', null);
    // Wait to avoid the enter event to be propagated as an enterClick to 'create'
    return this.setTimeout(_.focusInput.bind(null, this.ui.placeholderLabelEditor), 100);
  },

  hidePlaceholderEditor() {
    this.ui.head.removeClass('force-hidden');
    this.ui.placeholderEditor.addClass('hidden');
    this.$el.attr('tabindex', 0);
    return this.$el.focus();
  },

  create() {
    if (!this.model.get('isPlaceholder')) { return Promise.resolve(); }
    const lang = this.ui.langSelector.val();
    const label = this.ui.placeholderLabelEditor.val();
    this.model.resetLabels(lang, label);
    return this.model.create()
    .then(this.replaceModel.bind(this));
  },

  replaceModel(newModel){
    newModel.set('ordinal', this.model.get('ordinal'));
    this.model.collection.add(newModel);
    return this.model.collection.remove(this.model);
  },

  onKeyDown(e){
    const key = getActionKey(e);
    switch (key) {
      case 'enter': return this.showPlaceholderEditor();
      case 'esc': return this.hidePlaceholderEditor();
    }
  },

  propagateLangChange(e){
    const { value } = e.currentTarget;
    return app.vent.trigger('lang:local:change', value);
  },

  onOtherLangSelectorChange(value){
    if (this.ui.placeholderEditor.hasClass('hidden')) { return this.ui.langSelector.val(value); }
  },

  spreadAuthors() {
    const currentAuthorsUris = this.model.get('claims.wdt:P50') || [];
    const authorsSuggestionsUris = _.difference(this.allAuthorsUris, currentAuthorsUris);
    return { currentAuthorsUris, authorsSuggestionsUris };
  }});

var getPossibleOrdinals = function(nonPlaceholdersOrdinals){
  const maxOrdinal = nonPlaceholdersOrdinals.slice(-1)[0] || -1;
  return _.range(0, (maxOrdinal + 10))
    .filter(num => !nonPlaceholdersOrdinals.includes(num));
};
