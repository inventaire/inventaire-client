module.exports = (Items)->
  Items.transactions =
    giving:
      id: 'giving'
      icon: 'heart'
      label: 'giving'
      labelShort: "I'm giving it"
      unicodeIcon:'&#xf004;'
    lending:
      id: 'lending'
      icon: 'refresh'
      label: 'lending'
      labelShort: "I can lend it"
      unicodeIcon:'&#xf021;'
    selling:
      id: 'selling'
      icon: 'money'
      label: 'selling'
      labelShort: "I'm selling it"
      unicodeIcon:'&#xf0d6;'
    inventorying:
      id: 'inventorying'
      icon: 'cube'
      label: 'in my inventory'
      labelShort: 'in my inventory'
      unicodeIcon:'&#xf1b2;'
