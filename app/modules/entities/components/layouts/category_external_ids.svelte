<script>
  import { categoryLabels } from '#entities/lib/entity_links'
  import EntityClaimLink from '#entities/components/layouts/entity_claim_link.svelte'
  import { user } from '#user/user_store'
  import { I18n, i18n } from '#user/lib/i18n'
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

{#if categoryAvailableExternalIds.length > 0}
  <p class="category" dir={getTextDirection($user?.language)}>
    <span class="category-label">{I18n(categoryLabels[category])}:</span>
    {#each displayedCategoryExternalIds as { property, name, value }, i}
      <EntityClaimLink {property} {name} {value} />{#if i !== displayedCategoryExternalIds.length - 1},&nbsp;{/if}
    {/each}
    {#if categoryPreferredAvailableExternalIds.length !== categoryAvailableExternalIds.length}
      <button on:click={() => showAllAvailableExternalIds = !showAllAvailableExternalIds}>
        {#if showAllAvailableExternalIds}
          {@html icon('chevron-left')}
          {i18n('display less')}
        {:else}
          {@html icon('chevron-right')}
          {#if categoryPreferredAvailableExternalIds.length === 0}
            {i18n('display_x_links', { smart_count: categoryAvailableExternalIds.length })}
          {:else}
            {i18n('display_x_more', { smart_count: categoryAvailableExternalIds.length - categoryPreferredAvailableExternalIds.length })}
          {/if}
        {/if}
      </button>
    {/if}
  </p>
{/if}

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
