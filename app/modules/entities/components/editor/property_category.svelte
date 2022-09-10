<script>
  import { propertiesCategories } from '#entities/lib/editor/properties_per_type'
  import { I18n } from '#user/lib/i18n'
  import PropertyClaimsEditor from './property_claims_editor.svelte'
  import { icon } from '#lib/handlebars_helpers/icons'

  export let entity, category, categoryProperties

  const { label: categoryLabel } = (propertiesCategories[category] || {})

  let showCategory
  if (categoryLabel == null) showCategory = true

  const customProperties = app.user.get('customProperties')

  let scrollMarkerEl

  const id = `${category}-category-properties`

  function scroll () {
    scrollMarkerEl.scrollIntoView({ block: 'start', inline: 'nearest', behavior: 'smooth' })
  }

  function toggle () {
    showCategory = !showCategory
    if (showCategory) {
      // Wait for transitions to be over before attempting to scroll
      setTimeout(scroll, 200)
    }
  }

  function isDisplayingClaimEditor (property) {
    if (!categoryLabel) return true
    return customProperties.includes(property)
  }

  function isDisplayingCategoryTitle () {
    if (!categoryLabel) return false
    const categoryPropertiesList = Object.keys(categoryProperties)
    const categoryCustomProperties = _.intersection(categoryPropertiesList, customProperties)
    return _.some(categoryCustomProperties)
  }
</script>

{#if isDisplayingCategoryTitle()}
  <button
    aria-controls={id}
    class:active={showCategory}
    on:click={toggle}
    >
    {@html icon('caret-right')}
    <h3>{I18n(categoryLabel)}</h3>
    <div class="scroll-marker" bind:this={scrollMarkerEl}></div>
  </button>
{/if}

{#if showCategory}
  <div {id} class="category-properties">
    {#each Object.keys(categoryProperties) as property}
      {#if isDisplayingClaimEditor(property)}
        <PropertyClaimsEditor
          bind:entity
          {property}
        />
      {/if}
    {/each}
  </div>
{/if}

<style lang="scss">
  @import '#general/scss/utils';

  button{
    @include display-flex(row, center, flex-start);
    @include bg-hover($light-grey, 5%);
    @include radius;
    margin: 1em 0 0.5em 0;
    :global(.fa){
      font-size: 1.6rem;
      @include transition(transform, 0.2s);
      color: $grey;
    }
    h3{
      margin: 0;
    }
    &.active{
      :global(.fa){
        transform: rotate(90deg);
      }
    }
    position: relative;
  }
  .scroll-marker{
    position: absolute;
    top: -$topbar-height - 10;
  }
</style>
