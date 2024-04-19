const subdomain = sub => `https://${sub}.inventaire.io`
const image = filename => `/img/assets/${filename}`

export const domain = 'inventaire.io'
export const host = `https://${domain}`
export const blog = subdomain('blog')
export const git = subdomain('git')
export const wiki = subdomain('wiki')
export const faq = 'https://wiki.inventaire.io/wiki/FAQ'
export const communicationChannels = 'https://wiki.inventaire.io/wiki/Communication-channels'
export const chat = 'https://wiki.inventaire.io/wiki/Communication-channels#Chat'
export const translate = subdomain('translate')
export const roadmap = subdomain('roadmap')
export const apiDoc = subdomain('api')
export const dataHome = subdomain('data')

export const contact = {
  email: 'hello@inventaire.io',
  mailto: 'mailto:hello@inventaire.io',
}

export const images = {
  // not passing an absolute url so that it can be easily digested
  // by the {{imgSrc}} helper as a local image url
  // /!\ implies that the current server has it in its object storage container
  banner: image('banner.jpg'),
  // images in CC-BY or CC-BY-SA
  // See app/modules/welcome/views/templates/credits.hbs for originals
  bokeh: image('bokeh.jpg'),
  brittanystevens: image('brittanystevens.jpg'),
  defaultAvatar: image('default_avatar'),
}
