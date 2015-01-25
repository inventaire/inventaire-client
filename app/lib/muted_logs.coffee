try
  # local_config is never tracked by git
  # so you need to create one following this pattern:
  # module.exports =
  #   muted: []
  muted = require('../local_config').muted
catch err
  muted = []

# DONT COMMENT-OUT HERE, DO IT IN LOCAL_CONFIG
# here is just the full list of namespaces used in logs
all = [
  'i18n'
  'qLabel'
  'setCookie'
  'app'
  'route'
  'entity'
  'entities'
  'item'
  'items'
  'inv'
  'query'
  'relations'
  'data'
  'notifications'
  'cache'
]

module.exports = (_)-> _.intersection all, muted