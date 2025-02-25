const alwaysKeep = () => true

const redirectTest = section => allowRedirectPersistantQuery.includes(section)

const allowRedirectPersistantQuery = [
  'signup',
  'login',
  'authorize',
]

export default {
  debug: alwaysKeep,
  lang: alwaysKeep,
  redirect: redirectTest,
}
