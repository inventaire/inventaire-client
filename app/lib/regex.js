// Keep in sync with server/lib/regex

// adapted from http://stackoverflow.com/a/14582229/3324977
const urlPattern = '^(https?:\\/\\/)'+ // protocol
  '(\\w+:\\w+@)?'+ // auth?
  '((([a-z\\d]([a-z\\d-_]*[a-z\\d])*)\\.)+[a-z]{2,}|'+ // domain name
  '((\\d{1,3}\\.){3}\\d{1,3}))|'+ // OR ip (v4) address
  '(localhost)'+ // OR localhost
  '(\\:\\d+)?' + // port?
  '(\\/[-a-z\\d%_.~+]*)*'+ // path
  '(\\?[;&a-z\\d%_.~+=-]*)?'+ // query string?
  '(\\#[-a-z\\d_]*)?$'; //fragment?

export let Url = new RegExp(urlPattern , 'i');
export let ImageHash = /^[0-9a-f]{40}$/;
export let Email = /^[^@]+@[^@]+\.[^@]+$/;
export let Uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/;
export let CouchUuid = /^[0-9a-f]{32}$/;
export let Lang = /^\w{2}$/;
export let LocalImg = /^\/img\/(users|entities)\/[0-9a-f]{40}$/;
export let AssetImg = /^\/img\/assets\/\w/;
export let UserImg = /^\/img\/users\/[0-9a-f]{40}$/;
export let Username = /^\w{2,20}$/;
export let EntityUri = /^(wd:Q\d+|inv:[0-9a-f]{32}|isbn:\w{10}(\w{3})?)$/;
export let PropertyUri = /^(wdt|invp):P\d+$/;
export let SimpleDay = /^-?([1-9]{1}[0-9]{0,3}|0)(-\d{2})?(-\d{2})?$/;
