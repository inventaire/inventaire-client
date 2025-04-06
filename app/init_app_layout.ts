import { type SvelteComponent, type ComponentProps, type Component, mount } from 'svelte'
import AppLayout from '#components/app_layout.svelte'
import { commands } from './radio'

export let appLayout

export function initAppLayout () {
  const target = document.getElementById('app')
  // Remove spinner
  target.innerHTML = ''
  appLayout = mount(AppLayout, { target })
  appLayout.showChildComponent = showChildComponent
  appLayout.removeCurrentComponent = removeCurrentComponent
  commands.execute('waiter:resolve', 'layout')
  return appLayout
}

export interface RegionComponent {
  component: Component
  props?: ComponentProps<SvelteComponent>
}

type RegionName = 'main' | 'modal' | 'svelteModal'

function showChildComponent (regionName: RegionName, component: Component, options: { props?: ComponentProps<SvelteComponent> } = {}) {
  const props = 'props' in options ? options.props : {}
  if (component != null) {
    appLayout.$set({ [regionName]: { component, props } })
  } else {
    appLayout.$set({ [regionName]: null })
  }
}

function removeCurrentComponent (regionName: RegionName) {
  appLayout.$set({ [regionName]: null })
}
