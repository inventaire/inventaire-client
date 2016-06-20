module.exports =
  # minimanlist email regex
  # cf http://davidcel.is/blog/2012/09/06/stop-validating-email-addresses-with-regex/
  Email: /.+@.+\..+/i
  Uuid: /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/
  CouchUuid: /^[0-9a-f]{32}$/
  Lang: /^\w{2}$/
  LocalImg: /^\/img\/[0-9a-f]{40}.jpg$/
  # all 1 letter strings are reserved for the application
  Username: /^\w{2,20}$/
  EntityUri: /^(wd:Q\d+|inv:[0-9a-f]{32}|isbn:\w{10}(\w{3})?)$/
