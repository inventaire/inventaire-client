# building the path to use a partial from
# app/modules/transactions/views/templates/info
# with our custom {{partial}} handlebars helper
# (see app/lib/handlebars_helpers/partials.coffee)
partialPath = (filename)-> { partialPath: "transactions:info/#{filename}" }
i18nKey = (key)-> { i18nKey: key }

# mapping transaction mode and next actions to info partial files
# in the folder app/modules/transactions/views/templates/info
# or, for simple text, to a i18nKey
module.exports =
  giving:
    'accept_request': partialPath 'accept_request_one_way'
    # 'decline_request':
    'confirm_reception': i18nKey 'confirm_reception_one_way'
    # 'waiting_accepted':
    'waiting_confirmation': partialPath 'waiting_confirmation_one_way'
  lending:
    'accept_request': partialPath 'accept_request_lending'
    # 'decline_request':
    # 'confirm_reception':
    # 'confirm_returned':
    # 'waiting_accepted':
    'waiting_confirmation': i18nKey 'book_displayed_unavailable'
    # 'waiting_return_confirmation':
  selling:
    'accept_request': partialPath 'accept_request_one_way'
    # 'decline_request':
    'confirm_reception': i18nKey 'confirm_reception_one_way'
    # 'waiting_accepted':
    'waiting_confirmation': partialPath 'waiting_confirmation_one_way'
  inventorying: {}
