import ClaimsEditorCommons from './claims_editor_commons';
import createEntities from 'modules/entities/lib/create_entities';
import autocomplete from 'modules/entities/views/editor/lib/autocomplete';

export default ClaimsEditorCommons.extend({
  mainClassName: 'entity-value-editor',
  template: require('./templates/entity_value_editor'),
  behaviors: {
    AlertBox: {},
    Tooltip: {},
    PreventDefault: {}
  },

  ui: {
    input: 'input',
    save: '.save',
    selectedSuggestionStatus: '.selectedSuggestionStatus'
  },

  regions: {
    suggestionsRegion: '.suggestionsContainer'
  },

  initialize() {
    this.property = this.model.get('property');
    this.allowEntityCreation = this.model.get('allowEntityCreation');
    return this.initEditModeState();
  },

  lazyRenderIfDisplayMode() { if (!this.editMode) { return this.lazyRender(); } },

  serializeData() {
    const attrs = this.model.toJSON();
    attrs.editMode = this.editMode;
    attrs.valueEntity = this.valueEntityData();
    attrs.value = attrs.valueEntity?.label || attrs.value;
    if (attrs.valueEntity != null) {
      attrs.valueEntity.hasIdentifierTooltipLinks = (attrs.valueEntity.type != null) || (attrs.valueEntity.wikidata != null);
    }
    return attrs;
  },

  valueEntityData() {
    const { valueEntity } = this.model;
    if (valueEntity != null) {
      const data = valueEntity.toJSON();
      // Do not display an image if it's not the entity's own image
      // (e.g. if it's a work that deduced an image from one of its editions)
      // as it might be confusing
      if (data.claims['invp:P2'] == null) { delete data.image; }
      return data;
    }
  },

  modelEvents: {
    'grab': 'onGrab',
    'change:value': 'lazyRender'
  },

  onShow() {
    this.listenTo(app.vent, 'entity:value:editor:edit', this.preventMultiEdit.bind(this));

    if (this.editMode) {
      this.triggerEditEvent();
      return this.ui.input.focus();
    }
  },

  onGrab() {
    const { valueEntity } = this.model;
    if (valueEntity != null) {
      if (valueEntity.usesImagesFromSubEntities) { valueEntity.fetchSubEntities(); }
      this.listenToOnce(valueEntity, 'change:image', this.lazyRenderIfDisplayMode.bind(this));
      // init suggestion with the current value entity so that
      // saving without any change is equivalent to re-selecting the current value
      if (!this.suggestion) { this.suggestion = valueEntity; }
    }

    return this.lazyRender();
  },

  onRender() {
    this.selectIfInEditMode();
    if (this.editMode) {
      this.updateInputState();
      return autocomplete.onRender.call(this);
    }
  },

  events: {
    'click .edit, .displayModeData': 'showEditMode',
    'click .cancel': 'hideEditMode',
    'click .save': 'save',
    'click .delete': 'delete',
    'click .close': 'hideDropdown',
    'keyup input': 'onKeyUp'
  },

  onKeyUp(e){
    ClaimsEditorCommons.prototype.onKeyUp.call(this, e);
    if (this.editMode) { autocomplete.onKeyUp.call(this, e); }
    return this.updateInputState();
  },

  onKeyDown(e){
    if (this.editMode) { return autocomplete.onKeyDown.call(this, e); }
  },

  showDropdown: autocomplete.showDropdown,
  hideDropdown: autocomplete.hideDropdown,
  showLoadingSpinner: autocomplete.showLoadingSpinner,
  stopLoadingSpinner: autocomplete.stopLoadingSpinner,

  // this is a jQuery select, not an autocomplete one
  select() { return this.ui.input.select(); },

  onAutoCompleteSelect(suggestion){
    this.suggestion = suggestion;
    return this.updateInputState();
  },

  onAutoCompleteUnselect() {
    this.suggestion = null;
    return this.updateInputState();
  },

  // An event to tell every other value editor of the same property
  // that this view passes in edit mode and thus that other view in edit mode
  // should toggle to display mode
  triggerEditEvent() {
    return app.vent.trigger('entity:value:editor:edit', this.property, this.cid);
  },

  preventMultiEdit(property, viewCid){
    if (this.editMode && (property === this.property) && (this.cid !== viewCid)) {
      return this.hideEditMode();
    }
  },

  // TODO: prevent an existing entity to be re created just
  // because we passed in edit mode and clicked save
  save() {
    const uri = this.suggestion?.get('uri');
    // if the suggestion is the same as the current value, ignore
    if (uri === this.model.get('value')) { return this.hideEditMode(); }

    if (this.suggestion != null) { return this._save(uri); }

    if (!this.allowEntityCreation) { return; }

    const name = this.ui.input.val();
    const relationEntity = this.options.model.entity;
    // Assumes that the user has Wikidata Oauth setup as they are on the editor for a Wikidata entity
    const createOnWikidata = this.model.entity.get('isWikidataEntity');

    return createEntities.byProperty({ property: this.property, name, relationEntity, createOnWikidata })
    .then(_.Log('created entity'))
    .then(entity=> this._save(entity.get('uri')));
  },

  updateInputState() {
    if (!this.editMode) { return; }
    const value = this.ui.input.val();

    if (value === '') {
      this.ui.save.addClass('disabled');
    } else if (this.allowEntityCreation || (this.suggestion != null)) {
      this.ui.save.removeClass('disabled');
    } else {
      this.ui.save.addClass('disabled');
    }

    if (value === '') {
      this.ui.selectedSuggestionStatus.text('');
      return this.ui.input.removeClass('large');
    } else if (this.suggestion != null) {
      this.ui.selectedSuggestionStatus.text(this.suggestion.get('uri'));
      return this.ui.input.addClass('large');
    } else if (this.allowEntityCreation) {
      const type = createdEntityType[this.searchType];
      this.ui.selectedSuggestionStatus.text(_.i18n(`saving would create a new ${type}`));
      return this.ui.input.addClass('large');
    }
  }
});

// Types that have a allowEntityCreation flag
var createdEntityType = {
  works: 'work',
  humans: 'author',
  series: 'serie',
  publishers: 'publisher',
  collections: 'collection'
};
