module.exports = (metadata = {})-> _.extend defaultMetadata(), metadata

defaultMetadata = ->
  title: 'Inventaire - ' + _.i18n 'your friends and communities are your best library'
  description: _.I18n 'make the inventory of your books and mutualize with your friends and communities into an infinite library!'
  image: 'https://inventaire.io/public/images/inventaire-books.jpg'
  rss: 'http://blog.inventaire.io/rss'
