import { shortLang, isOpenedOutside, deepClone } from 'lib/utils'
import ChangeUserPicture from 'modules/user/lib/change_user_picture'
import profileSettingsTemplate from './templates/profile_settings.hbs'

import { i18n } from 'modules/user/lib/i18n'
import username_ from 'modules/user/lib/username_tests'
import forms_ from 'modules/general/lib/forms'
import error_ from 'lib/error'
import behaviorsPlugin from 'modules/general/plugins/behaviors'
import { testAttribute, pickerData } from '../lib/helpers'
import { updateLimit } from 'lib/textarea_limit'
import { languages as activeLanguages } from 'lib/active_languages'

export default Marionette.ItemView.extend({
  template: profileSettingsTemplate,
  className: 'profileSettings',
  behaviors: {
    AlertBox: {},
    ElasticTextarea: {},
    Loading: {},
    SuccessCheck: {},
    PreventDefault: {}
  },

  ui: {
    username: '#usernameField',
    bioTextarea: '#bio',
    bioLimit: '.bioLimit'
  },

  initialize () {
    _.extend(this, behaviorsPlugin)
    this.listenTo(this.model, 'change:picture', this.render)
    this.listenTo(this.model, 'change:position', this.render)
    this.lazyBioUpdate = _.debounce(updateLimit.bind(this, 'bioTextarea', 'bioLimit', 1000), 200)
  },

  serializeData () {
    const attrs = this.model.toJSON()
    return _.extend(attrs, {
      userPathname: app.user.get('pathname'),
      usernamePicker: this.usernamePickerData(),
      changePicture: {
        classes: 'max-large-profilePic'
      },
      hasPosition: this.model.hasPosition(),
      position: this.model.getCoords()
    })
  },

  onRender () { this.lazyBioUpdate() },

  usernamePickerData () { return pickerData(this.model, 'username') },

  languagesData () {
    const languages = deepClone(activeLanguages)
    const currentLanguage = shortLang(this.model.get('language'))
    if (languages[currentLanguage] != null) {
      languages[currentLanguage].selected = true
    }
    return languages
  },

  events: {
    'click a#changePicture': 'changePicture',
    'click a#usernameButton': 'updateUsername',
    'click #saveBio': 'saveBio',
    'keydown textarea#bio' () { this.lazyBioUpdate() },
    'click #showPositionPicker' () { app.execute('show:position:picker:main:user') },
    'click .done': 'showMainUserInventory'
  },

  // USERNAME
  updateUsername () {
    const username = this.ui.username.val()
    return Promise.try(this.testUsername.bind(this, username))
    .then(() => {
      // if the username update is just a change in case
      // it should be rejected because the username is already taken
      // which it will be given usernames concurrency is case insensitive
      if (this.usernameCaseChange(username)) {
      } else {
        return username_.verifyUsername(username, '#usernameField')
      }
    })
    .then(() => this.confirmUsernameChange(username))
    .catch(forms_.catchAlert.bind(null, this))
  },

  usernameCaseChange (username) {
    return username.toLowerCase() === this.model.get('username').toLowerCase()
  },

  testUsername (username) {
    return testAttribute('username', username, username_)
  },

  confirmUsernameChange (username) {
    const action = this.updateUserUsername.bind(this, username)
    return this.askConfirmation(action, {
      requestedUsername: username,
      currentUsername: app.user.get('username'),
      usernameCaseChange: this.usernameCaseChange(username),
      model: this.model
    }
    )
  },

  askConfirmation (action, args) {
    const { usernameCaseChange } = args
    app.execute('ask:confirmation', {
      confirmationText: i18n('username_change_confirmation', args),
      // no need to show the warning if it's just a case change
      warningText: !usernameCaseChange ? i18n('username_change_warning') : undefined,
      action,
      selector: '#usernameGroup'
    }
    )
  },

  updateUserUsername (username) {
    return app.request('user:update', {
      attribute: 'username',
      value: username,
      selector: '#usernameButton'
    }
    )
  },

  // BIO
  saveBio () {
    const bio = this.ui.bioTextarea.val()

    return Promise.try(validateBio.bind(null, bio))
    .then(updateUserBio.bind(null, bio))
    .catch(error_.Complete('#bio'))
    .catch(forms_.catchAlert.bind(null, this))
  },

  // PICTURE
  changePicture: ChangeUserPicture,

  // DONE
  showMainUserInventory (e) {
    if (!isOpenedOutside(e)) { app.execute('show:inventory:main:user') }
  }
})

const validateBio = function (bio) {
  if (bio.length > 1000) {
    throw error_.new("the bio can't be longer than 1000 characters", { length: bio.length })
  }
}

const updateUserBio = bio => app.request('user:update', {
  attribute: 'bio',
  value: bio,
  selector: '#bio'
}
)
