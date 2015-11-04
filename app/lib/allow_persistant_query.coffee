alwaysKeep = -> true

redirectTest = (section)->
  section in allowRedirectPersistantQuery

allowRedirectPersistantQuery = [
  'signup'
  'login'
]

module.exports =
  lang: alwaysKeep
  redirect: redirectTest
