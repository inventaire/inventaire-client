const [ target ] = process.argv.slice(2)

export default function () {
  if (target === 'prod') {
    return 'https://inventaire.io'
  } else {
    return 'http://localhost:3006'
  }
}
