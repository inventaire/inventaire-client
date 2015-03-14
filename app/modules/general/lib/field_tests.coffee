module.exports = 
  validate: (options)->
    {field, value, success, view, selector, tests} = options
    for err, test of tests
      if test(value)
        @invalidValue view, err, field, selector
        return false
    return success(value)

  invalidValue: (view, err, field, selector)->
    if _.isString err then errMessage = err
    else
      errMessage = err.responseJSON.status_verbose or "invalid #{field}"

    view.$el.trigger 'alert',
      message: _.i18n(errMessage)
      selector: selector