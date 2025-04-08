import { svelte } from '@sveltejs/vite-plugin-svelte'
import { defineConfig } from 'vite'
// import tsconfigPaths from 'vite-tsconfig-paths'
import pkg from './package.json' with { type: 'json' }

const aliases = Object.fromEntries(Object.entries(pkg.imports).map(([ alias, path ]) => {
  return [
    alias.replace('/*', ''),
    path.replace('/*', '/'),
  ]
}))

const projectRoot = import.meta.dirname

// const resolvePlugin = tsconfigPaths({
//   // to support resolve alias in scss files(any other non-script files)
//   loose: true,
// })

function getFilenameExtension (path: string) {
  const filename = path.split('/').at(-1) as string
  return filename.split('.').at(-1) as string
}

function resolveAlias (source: string) {
  console.error('🚀 ~ file: vite.config.ts ~ line', 27, 'customResolver ~ ', { source })
  if (source[0] === '/') return `${projectRoot}/app${source}`
  if (source[0] !== '#') return source
  const [ base, ...rest ] = source.split('/')
  const resolvedAlias = aliases[base]
  console.error('🚀 ~ file: vite.config.ts ~ line', 19, 'customResolver ~ ', { resolvedAlias, source, base, rest })
  if (resolvedAlias == null) return source
  return `${projectRoot}/${resolvedAlias}/${rest.join('/')}`
}

const validExtensions = new Set([ 'ts', 'svelte', 'scss' ])
function resolveExtension (resolvedId: string, importer: string) {
  const extension = getFilenameExtension(resolvedId)
  const importerExtension = getFilenameExtension(importer)
  if (importerExtension === 'scss') {
    const parts = resolvedId.split('/')
    resolvedId = `${parts.slice(0, -1).join('/')}/_${parts.at(-1)}`
    console.error('🚀 ~ file: vite.config.ts ~ line', 43, 'resolveExtension ~ ', { resolvedId })
  }
  if (validExtensions.has(extension)) {
    return resolvedId
  } else {
    const inheritedExtension = getFilenameExtension(importer)
    return `${resolvedId}.${inheritedExtension}`
  }
}

function customResolver (source: string, importer, options) {
  const resolvedId = resolveExtension(resolveAlias(source), importer)
  console.error('🚀 ~ file: vite.config.ts ~ line', 50, 'customResolver ~ ', { resolvedId })
  return resolvedId
}

// https://vite.dev/config/
export default defineConfig({
  plugins: [ svelte() ],
  root: './app',
  publicDir: false,
  // See https://github.com/aleclarson/vite-tsconfig-paths/issues/30#issuecomment-1829923317
  resolve: {
    alias: [
      {
        find: /(.*)/,
        replacement: '$1',
        customResolver,
      },
    ],
  },
  css: {
    preprocessorOptions: {
      scss: {
        // api: 'legacy',
      },
    },
    postcss: {
    },
  },
})
