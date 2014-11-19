module.exports =
  Collection:
    Items: require 'modules/inventory/collections/items'
    Users: require 'modules/users/collections/users'
    Entities: require 'modules/entities/collections/entities'
    LocalEntities: require 'modules/entities/collections/local_entities'
    TemporaryEntities: require 'modules/entities/collections/temporary_entities'
    WikidataEntities: require 'modules/entities/collections/wikidata_entities'
    Local:
      WikidataEntities: require 'modules/entities/collections/local_wikidata_entities'
      TmpWikidataEntities: require 'modules/entities/collections/temporary_local_wikidata_entities'
      NonWikidataEntities: require 'modules/entities/collections/local_non_wikidata_entities'
      TmpNonWikidataEntities: require 'modules/entities/collections/temporary_local_non_wikidata_entities'
    NonWikidataEntities: require 'modules/entities/collections/non_wikidata_entities'

  Model:
    Filterable: require 'modules/general/models/filterable'
    MainUser: require 'modules/user/models/main_user'
    User: require 'modules/users/models/user'
    Item: require 'modules/inventory/models/item'
    WikidataEntity: require 'modules/entities/models/wikidata_entity'
    BookWikidataEntity: require 'modules/entities/models/book_wikidata_entity'
    AuthorWikidataEntity: require 'modules/entities/models/author_wikidata_entity'
    NonWikidataEntity: require 'modules/entities/models/non_wikidata_entity'

  Layout:
    App: require 'modules/general/views/app_layout'
    Inventory: require 'modules/inventory/views/inventory'

  Region:
    CommonEl: require 'modules/general/regions/common_el'

  View:
    Welcome: require 'modules/general/views/welcome'
    NotLoggedMenu: require 'modules/general/views/menu/not_logged_menu'
    AccountMenu: require 'modules/general/views/menu/account_menu'
    ListWithCounter: require 'modules/general/views/menu/list_with_counter'
    Signup:
      Step1: require 'modules/user/views/signup_step_1'
      Step2: require 'modules/user/views/signup_step_2'
    Login:
      Step1: require 'modules/user/views/login_step_1'
    EditUser: require 'modules/user/views/edit_user'
    ItemsList: require 'modules/inventory/views/items_list'
    ItemsColumns: require 'modules/inventory/views/items_columns'
    ItemLi: require 'modules/inventory/views/item_li'
    NoItem: require 'modules/inventory/views/no_item'
    ItemEditionForm: require 'modules/inventory/views/item_edition_form'
    InventoriesTabs: require 'modules/inventory/views/inventories_tabs'
    PersonalInventoryTools: require 'modules/inventory/views/personal_inventory_tools'
    FriendsInventoryTools: require 'modules/inventory/views/friends_inventory_tools'
    Users:
      Li: require 'modules/users/views/user_li'
      No: require 'modules/users/views/no_user'
      List: require 'modules/users/views/users_list'
    Behaviors:
      ConfirmationModal: require 'modules/general/views/behaviors/confirmation_modal'
      Loader: require 'modules/general/views/behaviors/loader'
      PicturePicker: require 'modules/general/views/behaviors/picture_picker'
      ChangePicture: require 'modules/general/views/behaviors/change_picture'
    Entities:
      Show: require 'modules/entities/views/entity_show'
      AuthorLi: require 'modules/entities/views/author_li'
      Search: require 'modules/entities/views/entities_search_form'
      Form:
        Book: require 'modules/entities/views/book'
        Other: require 'modules/entities/views/other'
        CategoryMenu: require 'modules/entities/views/category_menu'
        ValidationButtons: require 'modules/general/views/validation_buttons'
        Scanner: require 'modules/entities/views/scanner'
    Items:
      Creation: require 'modules/inventory/views/form/item_creation'
    Error: require 'modules/general/views/error'


  lib:
    i18n: require 'lib/i18n'
    utils: require 'lib/utils'
    foundation: require 'lib/foundation'
    wikidata: require 'lib/wikidata'
    books: require 'lib/books'
    imageHandler: require 'lib/image_handler'
    uncatchedErrorLogger: require 'lib/uncatched_error_logger'
