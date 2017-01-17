module.exports = (stack)->
  stack?.split '\n'
  .map (line)-> line.trim().replace location.root, ''
