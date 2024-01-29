<script>
  import { categoryLabels } from '#entities/lib/entity_links'
  import EntityClaimLink from '#entities/components/layouts/entity_claim_link.svelte'
  import { user } from '#user/user_store'
  import { I18n, i18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import { getTextDirection } from '#lib/active_languages'
  import DisplayedLinks from '#settings/components/displayed_links.svelte'
  import Modal from '#components/modal.svelte'

  export let category, categoryAvailableExternalIds

  let showAllAvailableExternalIds = false
  let showCategorySettings = false

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
      <button class="toggle-external-ids" on:click={() => showAllAvailableExternalIds = !showAllAvailableExternalIds}>
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
    {#if showAllAvailableExternalIds}
      <button title={i18n('Customize which links should be displayed')} on:click={() => showCategorySettings = true}>
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
