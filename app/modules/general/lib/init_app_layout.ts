import AppLayout from '#components/app_layout.svelte'
import type { SvelteComponent, ComponentProps, ComponentType } from 'svelte'

let layout

export function initAppLayout () {
  const target = document.getElementById('app')
  // Remove spinner
  target.innerHTML = ''
  layout = new AppLayout({ target })
  layout.showChildComponent = showChildComponent
  layout.removeCurrentComponent = removeCurrentComponent
  return layout
}

export interface RegionComponent {
  component: ComponentType
  props?: ComponentProps<SvelteComponent>
}

type RegionName = 'main' | 'modal' | 'svelteModal'

function showChildComponent (regionName: RegionName, component: ComponentType, options: { props?: ComponentProps<SvelteComponent> } = {}) {
  const props = 'props' in options ? options.props : {}
  if (component != null) {
    layout.$set({ [regionName]: { component, props } })
  } else {
    layout.$set({ [regionName]: null })
  }
}

function removeCurrentComponent (regionName: RegionName) {
  layout.$set({ [regionName]: null })
}
