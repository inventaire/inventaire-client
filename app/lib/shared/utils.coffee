module.exports =
  # Returns a function ready to be called without accepting further arguments
  # usefull in promises chains, when the previous event might return
  # an unnecessary argument
  # It does nothing more than what would do an anonymous function
  # but it is explicit about what it does, while OCD-prone developers
  # might look at an anonymous function wanting to turn it into a named function
  Full: (fn, context, args...)-> fullFn = -> fn.apply context, args