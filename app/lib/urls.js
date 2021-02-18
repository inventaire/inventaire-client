const faircoinHash = 'fRFhk3DKubHmQu5i1NwY4mVErPVzXTtmDE'

const subdomain = sub => `http://${sub}.inventaire.io`
const image = filename => `/img/assets/${filename}`

export const host = 'https://inventaire.io'
export const blog = 'https://wiki.inventaire.io/wiki/Blog'
export const git = 'https://github.com/inventaire'
export const wiki = 'https://wiki.inventaire.io'
export const faq = 'https://wiki.inventaire.io/wiki/FAQ'
export const communicationChannels = 'https://wiki.inventaire.io/wiki/Communication-channels'
export const chat = 'https://wiki.inventaire.io/wiki/Communication-channels#chats'
export const translate = 'https://www.transifex.com/inventaire/inventaire'
export const roadmap = 'https://trello.com/b/0lKcsZDj/inventaire-roadmap'
export const apiDoc = subdomain('api')
export const dataHome = subdomain('data')

export const contact = {
  email: 'hello@inventaire.io',
  mailto: 'mailto:hello@inventaire.io'
}

export const images = {
  // not passing an absolute url so that it can be easily digested
  // by the {{imgSrc}} helper as a local image url
  // /!\ implies that the current server has it in its object storage container
  banner: image('banner.jpg'),
  // images in CC-BY or CC-BY-SA
  // see app/modules/welcome/views/templates/credits.hbs for originals
  bokeh: image('bokeh.jpg'),
  brittanystevens: image('brittanystevens.jpg'),
  defaultAvatar: image('default_avatar')
}

export const donate = {
  faircoin: {
    hash: faircoinHash,
    url: `faircoin:${faircoinHash}`
  },
  liberapay: 'https://liberapay.com/inventaire_io',
  paypal: 'https://www.paypal.me/inventaire/10'
}
