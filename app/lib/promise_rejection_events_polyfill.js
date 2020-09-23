// Based on https://github.com/ruodoo/odoo/blob/27d25b5315808dca946c609b5ebf4ca123772b64/addons/web/static/lib/unhandled-rejection-polyfill/unhandled-rejection-polyfill.js

const OriginalPromise = window.Promise;

const dispatchUnhandledRejectionEvent = function(promise, reason){
  const event = document.createEvent('Event');
  Object.defineProperties(event, {
    promise: { value: promise, writable: false },
    reason: { value: reason, writable: false }
  });
  event.initEvent('unhandledrejection', false, true);
  return window.dispatchEvent(event);
};

var patchedPromise = function(resolver){
  if (!(this instanceof patchedPromise)) {
    throw new TypeError('Cannot call a class as a function');
  }

  var promise = new OriginalPromise(function(resolve, reject){
    const customReject = function(reason){
      // macro-task (setTimeout) will execute after micro-task (promise)
      const fn = function() { if (!promise.handled) { return dispatchUnhandledRejectionEvent(promise, reason); } };
      setTimeout(fn, 0);
      return reject(reason);
    };

    try { return resolver(resolve, customReject); }
    catch (err) { return customReject(err); }
  });

  promise.__proto__ = patchedPromise.prototype;
  return promise;
};

patchedPromise.__proto__ = OriginalPromise;
patchedPromise.prototype.__proto__ = OriginalPromise.prototype;

const setHandledAndReject = function(reject){
  if (reject == null) { return; }
  return reason=> {
    this.handled = true;
    return reject(reason);
  };
};

patchedPromise.prototype.then = function(resolve, reject){
  return OriginalPromise.prototype.then.call(this, resolve, setHandledAndReject.call(this, reject));
};

patchedPromise.prototype.catch = function(reject){
  return OriginalPromise.prototype.catch.call(this, setHandledAndReject.call(this, reject));
};

export default function() {
  // Do not activate it in production as the patching isn't perfect:
  // chains of promises aren't all set as handled, despite a handler catching the error,
  // which results in error reports for errors that were actually handled
  if ((window.env === 'dev') && (typeof PromiseRejectionEvent === 'undefined')) {
    return window.Promise = patchedPromise;
  }
};
