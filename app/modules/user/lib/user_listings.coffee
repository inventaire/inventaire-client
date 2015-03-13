module.exports = (app)->
  app.user.listings =
    private:
      id: 'private'
      icon: 'lock'
      unicodeIcon: '&#xf023;'
      label: 'private'
    friends:
      id: 'friends'
      icon: 'users'
      unicodeIcon: '&#xf0c0;'
      label: 'shared with friends'
    public:
      id: 'public'
      icon: 'globe'
      unicodeIcon: '&#xf0ac;'
      label: 'public'