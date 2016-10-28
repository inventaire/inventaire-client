module.exports = (regex_)->
  isCouchUuid = regex_.CouchUuid.test.bind regex_.CouchUuid

  bindedTest = (regexName)-> regex_[regexName].test.bind regex_[regexName]

  return tests =
    isUrl: bindedTest 'Url'
    isIpfsPath: bindedTest 'IpfsPath'
    isLocalImg: bindedTest 'LocalImg'
    isLang: bindedTest 'Lang'
    isInvEntityId: isCouchUuid
    isEmail: bindedTest 'Email'
    isUserId: isCouchUuid
    isItemId: isCouchUuid
    isUsername: bindedTest 'Username'
    isEntityUri: bindedTest 'EntityUri'
    isPropertyUri: bindedTest 'PropertyUri'
    isSimpleDay: bindedTest 'SimpleDay'
