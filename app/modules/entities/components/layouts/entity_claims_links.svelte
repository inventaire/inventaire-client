<script>
  import { categoryLabels, getDisplayedPropertiesByCategory } from '#entities/lib/entity_links'
  import EntityClaimLink from '#entities/components/layouts/entity_claim_link.svelte'

  export let claims

  let categories = {}

  $: {
    for (const [ category, propertiesData ] of Object.entries(getDisplayedPropertiesByCategory())) {
      categories[category] = []
      for (const propertyData of propertiesData) {
        const { property } = propertyData
        if (claims[property]?.[0] != null) {
          categories[category].push({ ...propertyData, value: claims[property][0] })
        }
      }
    }
  }
</script>

<div class="entity-claims-links">
  {#each Object.entries(categories) as [ category, propertiesData ]}
    {#if propertiesData.length > 0}
      <p class="category">
        <span class="category-label">{categoryLabels[category]}:</span>
        {#each propertiesData as { property, label, value }}
          <EntityClaimLink {property} {label} {value} />
        {/each}
      </p>
    {/if}
  {/each}
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .category-label{
    color: $label-grey;
  }
</style>
