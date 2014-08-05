module.exports =
  Collection:
    Items: require 'collections/items'
    Contacts: require 'collections/contacts'

  Model:
    User: require 'models/user'
    Item: require 'models/item'
    Contact: require 'models/contact'

  Layout:
    App: require 'views/app_layout'

  View:
    Welcome: require 'views/welcome'
    NotLoggedMenu: require 'views/menu/not_logged_menu'
    AccountMenu: require 'views/menu/account_menu'
    Signup:
      Step1: require 'views/user/signup_step_1'
      Step2: require 'views/user/signup_step_2'
    Login:
      Step1: require 'views/user/login_step_1'
    EditUser: require 'views/user/edit_user'
    Inventory: require 'views/items/inventory'
    ItemsList: require 'views/items/items_list'
    ItemLi: require 'views/items/item_li'
    NoItem: require 'views/items/no_item'
    ItemCreationForm: require 'views/items/item_creation_form'
    ItemEditionForm: require 'views/items/item_edition_form'
    InventoriesTabs: require 'views/items/inventories_tabs'
    VisibilityTabs: require 'views/items/visibility_tabs'
    PersonalInventoryTools: require 'views/items/personal_inventory_tools'
    ContactsInventoriesTools: require 'views/items/contacts_inventories_tools'
    Contacts:
      Li: require 'views/contacts/contact_li'
      No: require 'views/contacts/no_contact'
      List: require 'views/contacts/contacts_list'
    Behaviors:
      ConfirmationModal: require 'views/behaviors/confirmation_modal'

  Lib:
    EventLogger: require 'lib/event_logger'

  Module:
    Foundation: require 'modules/foundation'
    User: require 'modules/user'
    Inventory: require 'modules/inventory'
    Contacts: require 'modules/contacts'