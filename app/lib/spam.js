export function looksLikeSpam (str) {
  return urlPattern.test(str) && suspectKeywordPattern.test(str)
}

const urlPattern = /(http|www\.|\w+\.\w+\/)/i

const suspectKeyword = [
  'SEO',
  'service',
  'customer',
  'printer',
  'professional',
  'escort',
  'assignment',
  'job',
  'content writer',
  'market',
  'business',
  'corporate',
  'support',
  'visit',
  'shopping',
  'gemstone',
  'product',
]

const suspectKeywordPattern = new RegExp(`(${suspectKeyword.join('|')})`, 'i')
