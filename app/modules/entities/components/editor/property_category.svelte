<script>
  import { propertiesCategories } from '#entities/lib/editor/properties_per_type'
  import { I18n } from '#user/lib/i18n'
  import PropertyClaimsEditor from './property_claims_editor.svelte'
  import WrapToggler from '#components/wrap_toggler.svelte'
  import { icon } from '#lib/icons'
  import { onChange } from '#lib/svelte/svelte'
  import { intersection, some, without } from 'underscore'
  import { reorderProperties } from '#entities/lib/properties'

  export let entity, category, categoryProperties
  export let requiredProperties = null

  const customProperties = app.user.get('customProperties')

  const { label: categoryLabel } = (propertiesCategories[category] || {})

  let showCategory

  let showAllProperties = categoryLabel == null
  let categoryCustomProperties, categoryAllProperties, displayedProperties
  $: {
    const categoryAllUnsortedProperties = Object.keys(categoryProperties)
    categoryCustomProperties = intersection(categoryAllUnsortedProperties, customProperties)
    categoryCustomProperties = reorderProperties(categoryCustomProperties)
    let notCategoryCustomProperties = without(categoryAllUnsortedProperties, ...customProperties)
    notCategoryCustomProperties = reorderProperties(notCategoryCustomProperties)
    categoryAllProperties = [ ...categoryCustomProperties, ...notCategoryCustomProperties ]
    displayedProperties = showAllProperties ? categoryAllProperties : categoryCustomProperties
  }

  function getIfCategoryHasActiveProperties () {
    if (!categoryLabel) return false
  }

  let scrollMarkerEl

  const id = `${category}-category-properties`

  function scroll () {
    scrollMarkerEl.scrollIntoView({ block: 'start', inline: 'nearest', behavior: 'smooth' })
  }

  function scrollToCategory () {
    if (!scrollMarkerEl) return
    // Wait for transitions to be over before attempting to scroll
    setTimeout(scroll, 200)
  }

  function toggle () {
    showCategory = !showCategory
    // Known case: in user settings, no custom properties of a category are checked.
    if (categoryCustomProperties.length === 0) showAllProperties = true
    if (showCategory) scrollToCategory()
  }

  $: onChange(customProperties, getIfCategoryHasActiveProperties)
  $: someCustomProperties = some(categoryCustomProperties)
  $: showCategory = (categoryLabel == null) || someCustomProperties
</script>

{#if categoryLabel}
  <button
    aria-controls={id}
    class:active={showCategory}
    on:click={toggle}
  >
    {@html icon('caret-right')}
    <h3>{I18n(categoryLabel)}</h3>
    <div class="scroll-marker" bind:this={scrollMarkerEl} />
  </button>
{/if}
{#if showCategory}
  <ul {id} class="category-properties">
    {#each displayedProperties as property (property)}
      <PropertyClaimsEditor
        bind:entity
        {property}
        required={requiredProperties?.includes(property)}
      />
    {/each}
  </ul>
  {#if categoryLabel && someCustomProperties && (categoryCustomProperties.length !== categoryAllProperties.length)}
    <div class="toggle-custom-properties">
      <WrapToggler
        bind:show={showAllProperties}
        moreText={I18n('show more properties')}
        lessText={I18n('show only main properties')}
      />
    </div>
  {/if}
{/if}

<style lang="scss">
  @import "#general/scss/utils";

  button{
    @include display-flex(row, center, flex-start);
    @include bg-hover($light-grey, 5%);
    @include radius;
    margin: 1em 0 0.5em;
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
    inset-block-start: -$topbar-height - 10;
  }
  .toggle-custom-properties{
    margin-inline-start: 0.5em;
  }
</style>
