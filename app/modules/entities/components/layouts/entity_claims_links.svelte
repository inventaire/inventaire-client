<script lang="ts">
  import { keys, pick, values } from 'underscore'
  import CategoryExternalIds from '#entities/components/layouts/category_external_ids.svelte'
  import { externalIdsDisplayConfigs } from '#entities/lib/entity_links'
  import type { Claims } from '#server/types/entity'

  export let claims: Claims

  const availableExternalIds = pick(externalIdsDisplayConfigs, keys(claims))
  const availableExternalIdsByCategory = {}
  for (const propertyData of values(availableExternalIds)) {
    const { property, category } = propertyData
    availableExternalIdsByCategory[category] = availableExternalIdsByCategory[category] || []
    availableExternalIdsByCategory[category].push({ ...propertyData, value: claims[property][0] })
  }
</script>

<div class="entity-claims-links">
  {#each Object.entries(availableExternalIdsByCategory) as [ category, categoryAvailableExternalIds ]}
    <CategoryExternalIds {category} {categoryAvailableExternalIds} />
  {/each}
</div>
