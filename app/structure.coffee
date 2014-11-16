module.exports =
  Collection:
    Items: require 'collections/items'
    Users: require 'modules/users/collections/users'
    Entities: require 'collections/entities'
    LocalEntities: require 'collections/local_entities'
    TemporaryEntities: require 'collections/temporary_entities'
    WikidataEntities: require 'collections/wikidata_entities'
    Local:
      WikidataEntities: require 'collections/local_wikidata_entities'
      TmpWikidataEntities: require 'collections/temporary_local_wikidata_entities'
      NonWikidataEntities: require 'collections/local_non_wikidata_entities'
      TmpNonWikidataEntities: require 'collections/temporary_local_non_wikidata_entities'
    NonWikidataEntities: require 'collections/non_wikidata_entities'

  Model:
    Filterable: require 'models/filterable'
    MainUser: require 'models/main_user'
    User: require 'modules/users/models/user'
    Item: require 'models/item'
    WikidataEntity: require 'models/wikidata_entity'
    BookWikidataEntity: require 'models/book_wikidata_entity'
    AuthorWikidataEntity: require 'models/author_wikidata_entity'
    NonWikidataEntity: require 'models/non_wikidata_entity'

  Layout:
    App: require 'views/app_layout'
    Inventory: require 'views/items/inventory'

  Region:
    CommonEl: require 'regions/common_el'

  View:
    Welcome: require 'views/welcome'
    NotLoggedMenu: require 'views/menu/not_logged_menu'
    AccountMenu: require 'views/menu/account_menu'
    ListWithCounter: require 'views/menu/list_with_counter'
    Signup:
      Step1: require 'views/user/signup_step_1'
      Step2: require 'views/user/signup_step_2'
    Login:
      Step1: require 'views/user/login_step_1'
    EditUser: require 'views/user/edit_user'
    ItemsList: require 'views/items/items_list'
    ItemLi: require 'views/items/item_li'
    NoItem: require 'views/items/no_item'
    ItemEditionForm: require 'views/items/item_edition_form'
    InventoriesTabs: require 'views/items/inventories_tabs'
    PersonalInventoryTools: require 'views/items/personal_inventory_tools'
    FriendsInventoryTools: require 'views/items/friends_inventory_tools'
    Users:
      Li: require 'modules/users/views/user_li'
      No: require 'modules/users/views/no_user'
      List: require 'modules/users/views/users_list'
    Behaviors:
      ConfirmationModal: require 'views/behaviors/confirmation_modal'
      Loader: require 'views/behaviors/loader'
      PicturePicker: require 'views/behaviors/picture_picker'
      ChangePicture: require 'views/behaviors/change_picture'
    Entities:
      Wikidata: require 'views/entities/wikidata_entity'
      AuthorLi: require 'views/entities/author_li'
      Search: require 'views/entities/entities_search_form'
      Form:
        Book: require 'views/entities/book'
        Other: require 'views/entities/other'
        CategoryMenu: require 'views/entities/category_menu'
        ValidationButtons: require 'views/entities/validation_buttons'
        Scanner: require 'views/entities/scanner'
    Items:
      Creation: require 'views/items/form/item_creation'
    Error: require 'views/error'


  lib:
    i18n: require 'lib/i18n'
    utils: require 'lib/utils'
    foundation: require 'lib/foundation'
    wikidata: require 'lib/wikidata'
    books: require 'lib/books'
    imageHandler: require 'lib/image_handler'
    uncatchedErrorLogger: require 'lib/uncatched_error_logger'
