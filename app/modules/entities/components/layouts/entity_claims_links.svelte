<script>
  import { categoryLabels, getDisplayedPropertiesByCategory } from '#entities/lib/entity_links'
  import EntityClaimLink from '#entities/components/layouts/entity_claim_link.svelte'
  import { I18n } from '#user/lib/i18n'

  export let claims

  let categories = {}

  for (const [ category, propertiesData ] of Object.entries(getDisplayedPropertiesByCategory())) {
    categories[category] = []
    for (const propertyData of propertiesData) {
      const { property } = propertyData
      if (claims[property]?.[0] != null) {
        categories[category].push({ ...propertyData, value: claims[property][0] })
      }
    }
  }
</script>

<div class="entity-claims-links">
  {#each Object.entries(categories) as [ category, propertiesData ]}
    {#if propertiesData.length > 0}
      <p class="category">
        <span class="category-label">{I18n(categoryLabels[category])}:</span>
        {#each propertiesData as { property, name, value }, i}
          <EntityClaimLink {property} {name} {value} />{#if i !== propertiesData.length - 1},&nbsp;{/if}
        {/each}
      </p>
    {/if}
  {/each}
</div>

<style lang="scss">
  @import "#general/scss/utils";
  .category-label{
    color: $label-grey;
  }
</style>
