<script lang="ts">
  import { objectEntries } from '#app/lib/utils'
  import EntityClaimLink from '#entities/components/layouts/entity_claim_link.svelte'
  import type { PropertyCategory } from '#entities/lib/editor/properties_per_type'
  import { categoryLabels, getDisplayedPropertiesByCategory, type DisplayConfig } from '#entities/lib/entity_links'
  import type { InvClaimValue } from '#server/types/entity'
  import { I18n } from '#user/lib/i18n'

  export let claims

  type CustomDisplayConfig = DisplayConfig & { value?: InvClaimValue }
  const categories: Partial<Record<PropertyCategory, CustomDisplayConfig[]>> = {}

  const displayedPropertiesByCategory = getDisplayedPropertiesByCategory()
  for (const [ category, propertiesData ] of objectEntries(displayedPropertiesByCategory)) {
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
