import clampedExtract from '../lib/clamped_extract';

export default Marionette.ItemView.extend({
  template: require('./templates/entity_data_overview'),
  className: 'entityDataOverview',
  initialize(options){
    this.hidePicture = options.hidePicture;
    if (!this.hidePicture) {
      return this.listenTo(this.model, 'add:pictures', this.lazyRender.bind(this));
    }
  },

  modelEvents: {
    'change': 'lazyRender'
  },

  serializeData() {
    const attrs = this.model.toJSON();
    clampedExtract.setAttributes(attrs);
    attrs.standalone = this.options.standalone;
    attrs.hidePicture = this.hidePicture;
    return attrs;
  },

  behaviors: {
    PreventDefault: {},
    ClampedExtract: {}
  },

  onRender() {
    return app.execute('uriLabel:update');
  }
});
