module.exports = (_)->
  # allow to pass the label first
  # useful when passing a function to a promise then or catch
  # -> allow to bind a label as first argument
  # doSomething.then _.log.bind(_, 'doing something')
  reorderObjLabel: (obj, label)->
    if label? and _.isString(obj) and not _.isString(label)
      return [label, obj]
    else
      return [obj, label]

  # allow to bind a label to a logger to be called later
  # assumes that the function accepts label as first argument
  # (that is, uses reorderObjLabel)
  bindLabel: (func, label)-> func.bind null, label