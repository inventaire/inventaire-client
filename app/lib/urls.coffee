faircoinHash = 'fRFhk3DKubHmQu5i1NwY4mVErPVzXTtmDE'

subdomain = (sub)-> "http://#{sub}.inventaire.io"
image = (name)-> "/img/assets/#{name}.jpg"

module.exports =
  contact:
    email: 'hello@inventaire.io'
    mailto: 'mailto:hello@inventaire.io'
  blog: subdomain 'blog'
  mastodon: 'http://mamot.fr/@inventaire'
  twitter: 'https://twitter.com/inventaire_io'
  facebook: 'https://facebook.com/inventaire.io'
  git: subdomain 'git'
  wiki: subdomain 'wiki'
  faq: 'https://wiki.inventaire.io/wiki/FAQ'
  chat: 'https://wiki.inventaire.io/wiki/Communication-channels#chats'
  translate: subdomain 'translate'
  roadmap: subdomain 'roadmap'
  apiDoc: subdomain 'api'
  images:
    # not passing an absolute url so that it can be easily digested
    # by the {{src}} helper as a local image url
    # /!\ implies that the current server has it in its object storage container
    banner: image 'banner'
    # images in CC-BY or CC-BY-SA
    # see app/modules/welcome/views/templates/credits.hbs for originals
    bokeh: image 'bokeh'
    brittanystevens: image 'brittanystevens'
  donate:
    faircoin:
      hash: faircoinHash
      url: "faircoin:#{faircoinHash}"
    liberapay: subdomain 'liberapay'
    paypal: subdomain 'paypal'
