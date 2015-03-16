module.exports = 
  pass: (options)->
    {value, tests, selector} = options
    for err, test of tests
      if test(value)
        err = new Error(err)
        err.selector = selector
        throw err

  validate: (options)->
    {field, value, success, view, selector, tests} = options
    for err, test of tests
      if test(value)
        @invalidValue view, err, selector
        return false
    return success(value)

  invalidValue: (view, err, selector)->
    if _.isString err then errMessage = err
    else
      errMessage = err.responseJSON?.status_verbose or err.message

    _.log errMessage, 'invalidValue errMessage'
    view.$el.trigger 'alert',
      message: _.i18n(errMessage)
      selector: selector