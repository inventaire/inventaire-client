<script>
  import { categoryLabels } from '#entities/lib/entity_links'
  import EntityClaimLink from '#entities/components/layouts/entity_claim_link.svelte'
  import { user } from '#user/user_store'
  import { i18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import { getTextDirection } from '#lib/active_languages'

  export let category, categoryAvailableExternalIds

  let showAllAvailableExternalIds = false

  let categoryPreferredAvailableExternalIds, displayedCategoryExternalIds
  $: {
    const { customProperties = [] } = $user
    categoryPreferredAvailableExternalIds = categoryAvailableExternalIds.filter(({ property }) => customProperties.includes(property))
  }
  $: displayedCategoryExternalIds = showAllAvailableExternalIds ? categoryAvailableExternalIds : categoryPreferredAvailableExternalIds
</script>

<p class="category" dir={getTextDirection($user?.language)}>
  <span class="category-label">{categoryLabels[category]}:</span>
  {#each displayedCategoryExternalIds as { property, name, value }, i}
    <EntityClaimLink {property} {name} {value} />{#if i !== displayedCategoryExternalIds.length - 1},{/if}
  {/each}
  {#if categoryPreferredAvailableExternalIds.length !== categoryAvailableExternalIds.length}
    <button on:click={() => showAllAvailableExternalIds = !showAllAvailableExternalIds}>
      {#if showAllAvailableExternalIds}
        {@html icon('chevron-left')}
        {i18n('display less')}
      {:else}
        {@html icon('chevron-right')}
        {i18n('display_x_more', { smart_count: categoryAvailableExternalIds.length - categoryPreferredAvailableExternalIds.length })}
      {/if}
    </button>
  {/if}
</p>

<style lang="scss">
  @import "#general/scss/utils";
  .category-label{
    color: $label-grey;
  }
  button{
    margin-inline-start: 0.5em;
    @include shy;
    :global(.fa){
      font-size: 0.8rem;
      width: 0.7rem;
    }
  }
  [dir="rtl"]{
    button :global(.fa){
      transform: rotate(180deg);
    }
  }
</style>
