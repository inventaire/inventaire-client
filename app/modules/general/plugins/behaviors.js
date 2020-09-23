// behaviors: Loading MUST be added to the view
// elements required in the view: .loading
// startLoading / stopLoading MUST NOT be called at view initialization
// but rathen onShow/onRender so that the expected DOM elements are rendered
const loading_ = {
  startLoading(params){
    if (_.isString(params)) { params = { selector: params }; }
    return this.$el.trigger('loading', params);
  },

  stopLoading(params){
    if (_.isString(params)) { params = { selector: params }; }
    return this.$el.trigger('stopLoading', params);
  }
};

// behaviors: SuccessCheck MUST be added to the view
// elements required in the view: .checkWrapper > .check
const successCheck_ = {
  check(label, cb, res){
    this.$el.trigger('check', cb);
    if ((label != null) && (res != null)) { return _.log(res, label); }
  },

  fail(label, cb, err){
    this.$el.trigger('fail', cb);
    if ((label != null) && (err != null)) { return _.error(err, label); }
  }
};

successCheck_.Check = function(label, cb){ return successCheck_.check.bind(this, label, cb); };
successCheck_.Fail = function(label, cb){ return successCheck_.fail.bind(this, label, cb); };

// behaviors: AlertBox MUST be added to the view
const alert_ = {
  alert(message){
    console.warn(message);
    this.$el.trigger('alert', { message: _.i18n(message) });
  }
};

// typical invocation: _.extend @, behaviorsPlugin
// ( and not behaviorsPlugin.call @ )
// allows to call functions only when needed: behaviorsPlugin.startLoading.call(@)
export default _.extend({}, loading_, successCheck_, alert_);
