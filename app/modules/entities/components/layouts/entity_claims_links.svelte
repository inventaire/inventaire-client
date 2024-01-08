<script>
  import { externalIdsDisplayConfigs } from '#entities/lib/entity_links'
  import CategoryExternalIds from '#entities/components/layouts/category_external_ids.svelte'
  import { pick } from 'underscore'

  export let claims

  const availableExternalIds = pick(externalIdsDisplayConfigs, Object.keys(claims))
  const availableExternalIdsByCategory = {}
  for (const propertyData of Object.values(availableExternalIds)) {
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
