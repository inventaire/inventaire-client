module.exports =
  Collection:
    Items: require "collections/items"

  Model:
    User: require "models/user"

  Layout:
    App: require 'views/app_layout'

  View:
    Inventory: require 'views/inventory'
    NotLoggedMenu: require 'views/not_logged_menu'
    AccountMenu: require 'views/account_menu'
    Signup:
      Step1: require 'views/auth/signup_step_1'
      Step2: require 'views/auth/signup_step_2'
    Login:
      Step1: require 'views/auth/login_step_1'

  Lib:
    idGenerator: require 'lib/id_generator'
    EventLogger: require 'lib/event_logger'

  Module:
    Auth: require 'modules/auth'