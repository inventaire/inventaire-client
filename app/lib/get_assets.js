// An API to get scripts that weren't bundled into vendor.js
// Names are expected to match app/api/scripts.coffee keys

const cache = {}

export default function (name, onScriptReady) {
  if (cache[name] != null) { return cache[name] }

  let promise = null
  let alreadyPrepared = false
  if (!onScriptReady) { onScriptReady = _.identity }

  const get = function () {
    if (promise == null) {
      _.log(name, 'fetching script')
      alreadyPrepared = true

      // Get the javascript file associated to this name
      const scriptPromise = _.preq.getScript(app.API.assets.scripts[name]())
        .then(onScriptReady)
        .catch(_.ErrorRethrow(`get script ${name}`))

      const _promises = [ scriptPromise ]

      // Get the stylesheet associated if any
      const stylesheetUrlGetter = app.API.assets.stylesheets[name]
      if (stylesheetUrlGetter != null) {
        _promises.push(_.preq.getCss(stylesheetUrlGetter()))
      }

      promise = Promise.all(_promises)
    }

    return promise
  }

  return cache[name] = {
    // Pre-fetch the script when the script is probably about to be used
    // to be ready to start using it faster
    prepare () {
      if (!alreadyPrepared) { get() }
      // We don't need to return a promise here
      // If we need a promise it's that be directly depend on the script arrival
      // thus 'get' should be used instead
      return null
    },
    get
  }
};
