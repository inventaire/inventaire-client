# Keep in sync with server/lib/boolean_tests

regex_ = requireProxy 'lib/regex'

isCouchUuid = regex_.CouchUuid.test.bind regex_.CouchUuid
bindedTest = (regexName)-> regex_[regexName].test.bind regex_[regexName]

isNonEmptyString = (str)-> _.isString(str) and str.length > 0

module.exports = tests =
  isUrl: bindedTest 'Url'
  isImageHash: bindedTest 'ImageHash'
  isLocalImg: bindedTest 'LocalImg'
  isAssetImg: bindedTest 'AssetImg'
  isUserImg: bindedTest 'UserImg'
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
    return isNonEmptyString(prefix) and isNonEmptyString(id)
  isPropertyUri: bindedTest 'PropertyUri'

  isNonNull: (obj)-> obj?
  isNonEmptyString: isNonEmptyString
  isNonEmptyArray: (array)-> _.isArray(array) and array.length > 0
  isNonEmptyPlainObject: (obj)->
    _.isPlainObject(obj) and Object.keys(obj).length > 0
  isPositiveIntegerString: (str)-> _.isString(str) and /^\d+$/.test str
  isPlainObject: (obj)-> _.typeOf(obj) is 'object'
  isModel: (obj)-> obj instanceof Backbone.Model
  isView: (obj)-> obj instanceof Backbone.View
  isCanvas: (obj)-> obj?.nodeName?.toLowerCase() is 'canvas'
