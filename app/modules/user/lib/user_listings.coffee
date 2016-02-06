module.exports = (app)->
  # made it a factory has its main use is to be cloned
  app.user.listings = ->
    private:
      id: 'private'
      icon: 'lock'
      unicodeIcon: '&#xf023;'
      label: 'private'
    friends:
      id: 'friends'
      icon: 'users'
      unicodeIcon: '&#xf0c0;'
      label: 'friends and groups'
    public:
      id: 'public'
      icon: 'globe'
      unicodeIcon: '&#xf0ac;'
      label: 'public'

  # keep a frozen version of the object at hand for read only
  app.user.listings.data = Object.freeze app.user.listings()
