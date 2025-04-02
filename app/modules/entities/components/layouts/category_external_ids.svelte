<script lang="ts">
  import { partition } from 'underscore'
  import { getTextDirection } from '#app/lib/active_languages'
  import { icon } from '#app/lib/icons'
  import Modal from '#components/modal.svelte'
  import EntityClaimLink from '#entities/components/layouts/entity_claim_link.svelte'
  import { categoryLabels } from '#entities/lib/entity_links'
  import DisplayedLinks from '#settings/components/displayed_links.svelte'
  import { I18n, i18n } from '#user/lib/i18n'
  import { mainUser, mainUserStore } from '#user/lib/main_user'
  import type { CategoryAvailableExternalId } from './entity_claims_links.svelte'
  import type { PropertyCategory } from '../../lib/editor/properties_per_type'

  export let category: PropertyCategory
  export let categoryAvailableExternalIds: CategoryAvailableExternalId[]

  let showAllAvailableExternalIds = false
  let showCategorySettings = false
  const linksId = `${category}Links`
  const { loggedIn } = mainUser

  let categoryPreferredAvailableExternalIds, categoryOtherAvailableExternalIds, displayedCategoryExternalIds
  $: {
    const { customProperties = [] } = $mainUserStore
    ;[ categoryPreferredAvailableExternalIds, categoryOtherAvailableExternalIds ] = partition(categoryAvailableExternalIds, ({ property }) => customProperties.includes(property))
  }
  $: {
    displayedCategoryExternalIds = categoryPreferredAvailableExternalIds
    // Keep the preferred properties first
    if (showAllAvailableExternalIds) displayedCategoryExternalIds = displayedCategoryExternalIds.concat(categoryOtherAvailableExternalIds)
  }
</script>

{#if categoryAvailableExternalIds.length > 0}
  <p class="category" dir={getTextDirection($mainUserStore?.language)}>
    <span class="category-label">{I18n(categoryLabels[category])}:</span>
    <span id={linksId}>
      {#each displayedCategoryExternalIds as { property, name, value, linkNum }, i (linkNum)}
        <EntityClaimLink {property} {name} {value} />{#if i !== displayedCategoryExternalIds.length - 1},&nbsp;{/if}
      {/each}
    </span>
    {#if categoryPreferredAvailableExternalIds.length !== categoryAvailableExternalIds.length}
      <button
        class="toggle-external-ids"
        on:click={() => showAllAvailableExternalIds = !showAllAvailableExternalIds}
        aria-controls={linksId}
      >
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
    {#if showAllAvailableExternalIds && loggedIn}
      <button title={i18n('Customize which links should be displayed')} class="customize" on:click={() => showCategorySettings = true}>
        {@html icon('cog')}
      </button>
    {/if}
  </p>
{/if}

{#if showCategorySettings}
  <Modal on:closeModal={() => showCategorySettings = false}>
    <div class="modal-inner">
      <h3>{i18n('Which links would you like to see by default?')}</h3>
      <DisplayedLinks {category} />
      <button class="tiny-button light-blue" on:click={() => showCategorySettings = false}>{I18n('done')}</button>
    </div>
  </Modal>
{/if}

<style lang="scss">
  @import "#general/scss/utils";
  .category-label{
    color: $label-grey;
  }
  .toggle-external-ids{
    margin-inline-start: 0.5em;
    @include shy;
    :global(.fa-chevron-left), :global(.fa-chevron-right){
      font-size: 0.8rem;
      width: 0.7rem;
    }
  }
  .customize{
    @include shy;
  }
  [dir="rtl"]{
    :global(.fa-chevron-left), :global(.fa-chevron-right){
      transform: rotate(180deg);
    }
  }
  h3{
    @include sans-serif;
    text-align: center;
    font-size: 1.1rem;
  }
  .modal-inner{
    margin: 1em;
    .tiny-button{
      display: block;
      margin: 0 auto;
    }
  }
</style>
