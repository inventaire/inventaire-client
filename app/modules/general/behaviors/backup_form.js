// A behavior to preserve input text from being lost on a view re-render
// by saving it at every change and recovering it on re-render
// This behavior should probably be added to any view with input or textarea
// that is suceptible to be re-rendered due to some event listener
export default Marionette.Behavior.extend({
  events: {
    'change input, textarea': 'backup',
    'click a': 'forget'
  },

  initialize() {
    return this._backup = {
      byId: {},
      byName: {}
    };
  },

  backup(e){
    // _.log @_backup, 'backup form data'
    const { id, value, type, name } = e.currentTarget;

    if (!_.isNonEmptyString(value)) { return; }
    if ((type !== 'text') && (type !== 'textarea')) { return; }

    if (_.isNonEmptyString(id)) { return this._backup.byId[id] = value;
    } else if (_.isNonEmptyString(name)) { return this._backup.byName[name] = value; }
  },

  recover() {
    customRecover(this.$el, this._backup.byId, buildIdSelector);
    return customRecover(this.$el, this._backup.byName, buildNameSelector);
  },

  // Listen on clicks on anchor with a 'data-forget' attribute
  // to delete the data associated with the form element related to this anchor.
  // Typically used on 'cancel' buttons
  forget(e){
    const forgetAttr = e.currentTarget.attributes['data-forget']?.value;
    if (forgetAttr != null) {
      _.log(forgetAttr, 'form:forget');
      if (forgetAttr[0] === '#') {
        const id = forgetAttr.slice(1);
        return delete this._backup.byId[id];
      } else {
        const name = forgetAttr;
        return delete this._backup.byName[name];
      }
    }
  },

  onRender() { return this.recover(); }
});

var customRecover = ($el, store, selectorBuilder) => (() => {
  const result = [];
  for (let key in store) {
    const value = store[key];
    _.log(value, key);
    const selector = selectorBuilder(key);
    result.push($el.find(selector).val(value));
  }
  return result;
})();

var buildIdSelector = id => `#${id}`;
var buildNameSelector = name => `[name='${name}']`;
