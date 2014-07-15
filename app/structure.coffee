module.exports =
  Collection:
    Items: require "collections/items"

  Model:
    User: require "models/user"

  Layout:
    App: require 'views/app_layout'

  View:
    Welcome: require 'views/welcome'
    NotLoggedMenu: require 'views/menu/not_logged_menu'
    AccountMenu: require 'views/menu/account_menu'
    Signup:
      Step1: require 'views/auth/signup_step_1'
      Step2: require 'views/auth/signup_step_2'
    Login:
      Step1: require 'views/auth/login_step_1'
    Inventory: require 'views/items/inventory'
    ItemsList: require 'views/items/items_list'
    ItemLi: require 'views/items/item_li'
    NoItem: require 'views/items/no_item'
    ItemCreationForm: require 'views/items/item_creation_form'
    ItemEditionForm: require 'views/items/item_edition_form'

  Lib:
    idGenerator: require 'lib/id_generator'
    EventLogger: require 'lib/event_logger'

  Module:
    Auth: require 'modules/auth'
    Inventory: require 'modules/inventory'