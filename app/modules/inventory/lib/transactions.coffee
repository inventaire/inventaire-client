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
      label: 'Just saying I have it'
      labelShort: 'I have it'
      unicodeIcon:'&#xf1b2;'
