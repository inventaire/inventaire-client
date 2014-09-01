module.exports =
  Collection:
    Items: require 'collections/items'
    Contacts: require 'collections/contacts'
    WikidataEntities: require 'collections/wikidata_entities'

  Model:
    User: require 'models/user'
    Item: require 'models/item'
    Contact: require 'models/contact'
    WikidataEntity: require 'models/wikidata_entity'

  Layout:
    App: require 'views/app_layout'
    Inventory: require 'views/items/inventory'

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
    ItemsList: require 'views/items/items_list'
    ItemLi: require 'views/items/item_li'
    NoItem: require 'views/items/no_item'
    ItemCreationForm: require 'views/items/item_creation_form'
    ItemEditionForm: require 'views/items/item_edition_form'
    InventoriesTabs: require 'views/items/inventories_tabs'
    VisibilityTabs: require 'views/items/visibility_tabs'
    PersonalInventoryTools: require 'views/items/personal_inventory_tools'
    ContactsInventoryTools: require 'views/items/contacts_inventory_tools'
    Contacts:
      Li: require 'views/contacts/contact_li'
      No: require 'views/contacts/no_contact'
      List: require 'views/contacts/contacts_list'
    Behaviors:
      ConfirmationModal: require 'views/behaviors/confirmation_modal'
      Loader: require 'views/behaviors/loader'
    Form:
      CategoryMenu: require 'views/items/form/category_menu'
      BookForm: require 'views/items/form/book'
      OtherForm: require 'views/items/form/other'
      ValidationButtons: require 'views/items/form/validation_buttons'
      PersonalData: require 'views/items/form/personal_data'
    Entities:
      Wikidata: require 'views/entities/wikidata_entity'


  lib:
    i18n: require 'lib/i18n'
    utils: require 'lib/utils'
    foundation: require 'lib/foundation'
    wikidata: require 'lib/wikidata'