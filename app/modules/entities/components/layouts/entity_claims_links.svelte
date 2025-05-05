<script context="module" lang="ts">
  import type { DisplayConfig } from '#entities/lib/entity_links'
  import type { InvClaimValue } from '#server/types/entity'
  import type { PropertyCategory } from '../../lib/editor/properties_per_type'

  export type CategoryAvailableExternalId = DisplayConfig & { value: InvClaimValue }
  export type AvailableExternalIdsByCategory = Record<PropertyCategory, CategoryAvailableExternalId[]>
</script>

<script lang="ts">
  import { keys, pick, values } from 'underscore'
  import { objectEntries } from '#app/lib/utils'
  import CategoryExternalIds from '#entities/components/layouts/category_external_ids.svelte'
  import { externalIdsDisplayConfigs } from '#entities/lib/entity_links'
  import type { Claims } from '#server/types/entity'

  export let claims: Claims

  const availableExternalIds = pick(externalIdsDisplayConfigs, keys(claims))
  const _availableExternalIdsByCategory = {}
  let linkNum = 0
  for (const propertyData of values(availableExternalIds)) {
    const { property, category } = propertyData
    _availableExternalIdsByCategory[category] = _availableExternalIdsByCategory[category] || []
    for (const value of claims[property]) {
      _availableExternalIdsByCategory[category].push({ ...propertyData, value, linkNum: linkNum++ })
    }
  }
  const availableExternalIdsByCategory = _availableExternalIdsByCategory as AvailableExternalIdsByCategory
</script>

<div class="entity-claims-links">
  {#each objectEntries(availableExternalIdsByCategory) as [ category, categoryAvailableExternalIds ]}
    <CategoryExternalIds {category} {categoryAvailableExternalIds} />
  {/each}
</div>
