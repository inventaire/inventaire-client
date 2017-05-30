host = 'https://inventaire.io'
root = if window.env is 'dev' then host else ''
bitcoinHash = '1QGMFXJevme8eNCusNmLddiecAiXspSguw'
faircoinHash = 'fRFhk3DKubHmQu5i1NwY4mVErPVzXTtmDE'

subdomain = (sub)-> "http://#{sub}.inventaire.io"

module.exports =
  host: host
  contact:
    email: 'hello@inventaire.io'
    mailto: 'mailto:hello@inventaire.io'
  blog: subdomain 'blog'
  twitter: 'https://twitter.com/inventaire_io'
  facebook: 'https://facebook.com/inventaire.io'
  git: subdomain 'git'
  wiki: subdomain 'wiki'
  faq: 'https://wiki.inventaire.io/wiki/FAQ'
  translate: subdomain 'translate'
  roadmap: subdomain 'roadmap'
  apiDoc: subdomain 'api'
  images:
    # not passing an absolute url so that it can be easily digested
    # by the {{src}} helper as a local image url
    # /!\ implies that the current server has it in its object storage container
    banner: "#{root}/img/a703e4c65a44dab0e9086722ac2967c3cdf03024.jpg"
    # images in CC-BY or CC-BY-SA
    # see app/modules/welcome/views/templates/credits.hbs for originals
    bokeh: "#{root}/img/6fca0921e336dd4dab1f1900e8f1143a9a9e9623.jpg"
    ginnerobot: "#{root}/img/28945a3c26a986b371767cfdb9d0e11156a6d641.jpg"
    brittanystevens: "#{root}/img/f3c063914d81996e3d262201d1e71c5e38212948.jpg"
  donate:
    bitcoin:
      hash: bitcoinHash
      url: "bitcoin:#{bitcoinHash}"
      # coinbase: subdomain 'coinbase'
      qrcode: "#{root}/img/f086157157209ee0b3a09ff7bd8eb88c79fb658d.jpg"

    faircoin:
      hash: faircoinHash
      url: "faircoin:#{faircoinHash}"
    gratipay: subdomain 'gratipay'
    liberapay: subdomain 'liberapay'
    paypal: subdomain 'paypal'
