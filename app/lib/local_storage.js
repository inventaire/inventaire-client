export default function() {
  // if localStorage isnt supported (or more probably, blocked),
  // replace it by a global object: data won't be persisted
  // from one session to the other, but who's fault is that
  let localStorageProxy;
  try {
    window.localStorage.setItem('localStorage-support', true);
    localStorageProxy = localStorage;
  } catch (err) {
    console.warn('localStorage isnt supported');
    let storage = {};
    localStorageProxy = {
      getItem(key){ return storage[key] || null; },
      setItem(key, value){
        storage[key] = value;
      },
      clear() { return storage = {}; }
    };
  }

  window.localStorageProxy = localStorageProxy;

  // simplified API to store boolean settings locally
  window.localStorageBool = {
    // take care of parsing the boolean string:
    // anything else than the string 'true' will be considered false
    get(key){ return localStorageProxy.getItem(key) === 'true'; },
    set: localStorageProxy.setItem.bind(localStorageProxy)
  };

  // Generate a minimalist API from a key
  // someSetting = localStorageBoolApi 'some-setting'
  // someSetting.get()
  // => true / false
  // someSetting.set(true) / someSetting.set(false)
  // => undefined
  return window.localStorageBoolApi = key => ({
    get() { return localStorageBool.get(key); },
    set(bool){ return localStorageBool.set(key, bool); }
  });
};
