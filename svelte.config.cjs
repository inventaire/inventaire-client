// eslint-disable-next-line @typescript-eslint/no-var-requires
const svelteWebpackConfig = require('./bundle/rules/svelte.cjs')('dev')

const { preprocess } = svelteWebpackConfig[0].use[0].options

// Share the preprocess config with the svelte-vscode extension, to be able to lint scss in vscode
// The extension relies on the language-server, see:
// https://github.com/sveltejs/language-tools/blob/master/docs/preprocessors/in-general.md
// https://github.com/sveltejs/language-tools/blob/master/docs/preprocessors/scss-less.md
module.exports = { preprocess }
