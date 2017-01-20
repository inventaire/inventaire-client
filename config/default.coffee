module.exports =
  # transifex doesn't use API keys or anything, just the same credentials as for an in browser login
  transifex:
    username: 'customize'
    password: 'customize'
  universalPath: require '../../config/universal_path'
  host: 'http://localhost:3006'
  prerenderUrl: 'http://localhost:3000'
  gitlabLogging:
    enabled: false
