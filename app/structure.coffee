# Just keep here modules that are called several times
# from outside their home module

behaviors = (name)-> require 'modules/general/views/behaviors/' + name
lib = (name)-> require 'lib/' + name

module.exports =
  Collection:
    Items: require 'modules/inventory/collections/items'

  View:
    Items:
      List: require 'modules/inventory/views/items_list'
    Users:
      List: require 'modules/users/views/users_list'
    Behaviors:
      ConfirmationModal: behaviors 'confirmation_modal'
      Loader: behaviors 'loader'
      PicturePicker: behaviors 'picture_picker'
      ChangePicture: behaviors 'change_picture'

  lib:
    i18n: lib 'i18n'
    foundation: lib 'foundation'
    wikidata: lib 'wikidata'
    books: lib 'books'