faircoinHash = 'fRFhk3DKubHmQu5i1NwY4mVErPVzXTtmDE'

subdomain = (sub)-> "http://#{sub}.inventaire.io"
image = (filename)-> "/img/assets/#{filename}"

module.exports =
  host: 'https://inventaire.io'
  contact:
    email: 'hello@inventaire.io'
    mailto: 'mailto:hello@inventaire.io'
  blog: subdomain 'blog'
  git: subdomain 'git'
  wiki: subdomain 'wiki'
  faq: 'https://wiki.inventaire.io/wiki/FAQ'
  communicationChannels: 'https://wiki.inventaire.io/wiki/Communication-channels'
  chat: 'https://wiki.inventaire.io/wiki/Communication-channels#chats'
  translate: subdomain 'translate'
  roadmap: subdomain 'roadmap'
  apiDoc: subdomain 'api'
  dataHome: subdomain 'data'
  images:
    # not passing an absolute url so that it can be easily digested
    # by the {{imgSrc}} helper as a local image url
    # /!\ implies that the current server has it in its object storage container
    banner: image 'banner.jpg'
    # images in CC-BY or CC-BY-SA
    # see app/modules/welcome/views/templates/credits.hbs for originals
    bokeh: image 'bokeh.jpg'
    brittanystevens: image 'brittanystevens.jpg'
    defaultAvatar: image 'default_avatar'
  donate:
    faircoin:
      hash: faircoinHash
      url: "faircoin:#{faircoinHash}"
    liberapay: subdomain 'liberapay'
    paypal: subdomain 'paypal'
