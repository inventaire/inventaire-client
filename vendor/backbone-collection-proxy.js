/* eslint-disable */

// backbone-collection-proxy 0.2.5 (MIT)
// https://github.com/jmorrell/backbone-collection-proxy

import _ from 'underscore'
import Backbone from './backbone'

// Methods in the collection prototype that we won't expose
var blacklistedMethods = [
  "_onModelEvent", "_prepareModel", "_removeReference", "_reset", "add",
  "initialize", "sync", "remove", "reset", "set", "push", "pop", "unshift",
  "shift", "sort", "parse", "fetch", "create", "model", "off", "on",
  "listenTo", "listenToOnce", "bind", "trigger", "once", "stopListening"
];

var eventWhiteList = [
  'add', 'remove', 'reset', 'sort', 'destroy', 'sync', 'request', 'error'
];

function proxyCollection(from, target) {

  function updateLength() {
    target.length = from.length;
  }

  function pipeEvents(eventName) {
    var args = _.toArray(arguments);
    var isChangeEvent = eventName === 'change' ||
                        eventName.slice(0, 7) === 'change:';

    // In the case of a `reset` event, the Collection.models reference
    // is updated to a new array, so we need to update our reference.
    if (eventName === 'reset') {
      target.models = from.models;
    }

    if (_.contains(eventWhiteList, eventName)) {
      if (_.contains(['add', 'remove', 'destroy'], eventName)) {
        args[2] = target;
      } else if (_.contains(['reset', 'sort'], eventName)) {
        args[1] = target;
      }
      target.trigger.apply(this, args);
    } else if (isChangeEvent) {
      // In some cases I was seeing change events fired after the model
      // had already been removed from the collection.
      if (target.contains(args[1])) {
        target.trigger.apply(this, args);
      }
    }
  }

  var methods = {};

  _.each(_.functions(Backbone.Collection.prototype), function(method) {
    if (!_.contains(blacklistedMethods, method)) {
      methods[method] = function() {
        return from[method].apply(from, arguments);
      };
    }
  });

  _.extend(target, Backbone.Events, methods);

  target.listenTo(from, 'all', updateLength);
  target.listenTo(from, 'all', pipeEvents);
  target.models = from.models;

  updateLength();
  return target;
}

export default proxyCollection;

