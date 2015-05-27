module.exports =
  # minimanlist email regex
  # cf http://davidcel.is/blog/2012/09/06/stop-validating-email-addresses-with-regex/
  Email: /.+@.+\..+/i
  Uuid: /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/
  CouchUuid: /^[0-9a-f]{32}$/
  Lang: /^\w{2}$/
