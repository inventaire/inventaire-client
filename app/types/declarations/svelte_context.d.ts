// Keep separated from `declare namespace svelteHTML` in ./svelte.d.ts
// as, for some reason, `Writable` import messes with `declare namespace svelteHTML`
// (that is, on:enterViewport show type errors again)
import type { PluralizedIndexedEntityType } from '#server/types/entity'
import type { Map, LayerGroup } from 'leaflet'
import type { Writable } from 'svelte/store'

// Inspired by https://github.com/sveltejs/svelte/issues/8941#issuecomment-1927036924
declare module 'svelte' {
  export function getContext(key: 'layer'): (() => LayerGroup)
  export function getContext(key: 'map'): (() => Map)
  export function getContext(key: 'work-layout:filters-store'): Writable
  export function getContext(key: 'layout-context'): string
  export function getContext(key: 'search-filter-claim'): string
  export function getContext(key: 'search-filter-types'): PluralizedIndexedEntityType[]
}
