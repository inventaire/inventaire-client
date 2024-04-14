// Addressing TS2345 errors such as:
// Object literal may only specify known properties, and '"on:enterViewport"' does not exist in type 'Omit<HTMLAttributes<HTMLDivElement>, never> & HTMLAttributes<any>'.ts(2353)
// See https://github.com/sveltejs/language-tools/blob/master/docs/preprocessors/typescript.md#im-getting-deprecation-warnings-for-sveltejsx--i-want-to-migrate-to-the-new-typings
// found via https://github.com/isaacHagoel/svelte-dnd-action/issues/445

// Reference: https://github.com/sveltejs/language-tools/blob/master/packages/svelte2tsx/svelte-jsx.d.ts
import type { Map, LayerGroup } from 'leaflet'
import type { Writable } from 'svelte/store'

declare namespace svelteHTML {
  interface HTMLAttributes {
    // Define event listners used by actions

    // See app/lib/components/actions/viewport.ts
    'on:enterViewport'?: (e: CustomEvent) => void
    'on:leaveViewport'?: (e: CustomEvent) => void
  }
}

// Inspired by https://github.com/sveltejs/svelte/issues/8941#issuecomment-1927036924
declare module 'svelte' {
  export function getContext(key: 'layer'): (() => LayerGroup)
  export function getContext(key: 'map'): (() => Map)
  export function getContext(key: 'work-layout:filters-store'): Writable
  export function getContext(key: 'layout-context'): string
  export function getContext(key: 'search-filter-claim'): string
  export function getContext(key: 'search-filter-types'): string
}
