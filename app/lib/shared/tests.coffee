module.exports = (regex_)->
  isCouchUuid = regex_.CouchUuid.test.bind regex_.CouchUuid

  bindedTest = (regexName)-> regex_[regexName].test.bind regex_[regexName]

  tests =
    isUrl: bindedTest 'Url'
    isIpfsPath: bindedTest 'IpfsPath'
    isLocalImg: bindedTest 'LocalImg'
    isLang: bindedTest 'Lang'
    isInvEntityId: isCouchUuid
    isEmail: bindedTest 'Email'
    isUserId: isCouchUuid
    isGroupId: isCouchUuid
    isItemId: isCouchUuid
    isUsername: bindedTest 'Username'
    isEntityUri: bindedTest 'EntityUri'
    isExtendedEntityUri: (uri)->
      [ prefix, id ] = uri.split ':'
      # Accept alias URIs.
      # Ex: twitter:Bouletcorp -> wd:Q1524522
      return _.isNonEmptyString(prefix) and _.isNonEmptyString(id)
    isPropertyUri: bindedTest 'PropertyUri'
    isSimpleDay: bindedTest 'SimpleDay'

  tests.isExtendedUrl = (str)-> tests.isUrl(str) or tests.isIpfsPath(str)

  return tests
