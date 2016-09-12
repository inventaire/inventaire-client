module.exports = (regex_)->
  isCouchUuid = regex_.CouchUuid.test.bind regex_.CouchUuid

  return tests =
    isLocalImg: (url)-> regex_.LocalImg.test url
    isLang: (lang)-> regex_.Lang.test lang
    isInvEntityId: isCouchUuid
    isEmail: (str)-> regex_.Email.test str
    isUserId: isCouchUuid
    isItemId: isCouchUuid
    isUsername: (username)-> regex_.Username.test username
    isEntityUri: (uri)-> regex_.EntityUri.test uri
