alwaysKeep = -> true

redirectTest = (section)->
  section in allowRedirectPersistantQuery

allowRedirectPersistantQuery = [
  'signup'
  'login'
]

module.exports =
  debug: alwaysKeep
  lang: alwaysKeep
  redirect: redirectTest
