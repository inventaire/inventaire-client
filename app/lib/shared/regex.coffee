module.exports =
  # minimanlist email regex
  # cf http://davidcel.is/blog/2012/09/06/stop-validating-email-addresses-with-regex/
  Email: /.+@.+\..+/i
  Uuid: /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/
  CouchUuid: /^[0-9a-f]{32}$/
  Lang: /^\w{2}$/
  LocalImg: /^\/img\/[0-9a-f]{40}.jpg$/
  Username: /^\w{1,20}$/
  EntityUri: /^(wd:Q[0-9]+|(isbn|inv):[\w\-]+)$/
