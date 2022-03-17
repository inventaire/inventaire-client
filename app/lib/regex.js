// See also server/lib/regex

export const ImageHash = /^[0-9a-f]{40}$/
// Source https://html.spec.whatwg.org/multipage/input.html#email-state-%28type=email%29
export const Email = /^[a-zA-Z0-9.!#$%&'*+\\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/
export const Uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/
export const CouchUuid = /^[0-9a-f]{32}$/
export const Lang = /^\w{2}$/
export const LocalImg = /^\/img\/(entities|groups|users)\/[0-9a-f]{40}$/
export const AssetImg = /^\/img\/assets\/\w/
export const UserImg = /^\/img\/users\/[0-9a-f]{40}$/
export const Username = /^[\p{Letter}\p{Number}_]{2,20}$/u
export const EntityUri = /^(wd:Q\d+|inv:[0-9a-f]{32}|isbn:\w{10}(\w{3})?)$/
export const PropertyUri = /^(wdt|invp):P\d+$/
export const SimpleDay = /^-?([1-9]{1}[0-9]{0,3}|0)(-\d{2})?(-\d{2})?$/
