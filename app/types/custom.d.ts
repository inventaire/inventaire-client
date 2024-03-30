// See https://webpack.js.org/guides/typescript/#importing-other-assets

declare module '*.svg' {
  const content: string
  export default content
}

declare module '*.png' {
  const content: string
  export default content
}

declare module '*.scss' {
  const content: string
  export default content
}

declare module '*.hbs' {
  const content: string
  export default content
}
