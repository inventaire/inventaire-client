<script>
  import { propertiesCategories } from '#entities/lib/editor/properties_per_type'
  import { I18n } from '#user/lib/i18n'
  import PropertyClaimsEditor from './property_claims_editor.svelte'
  import WrapToggler from '#components/wrap_toggler.svelte'
  import { icon } from '#lib/handlebars_helpers/icons'
  import { onChange } from '#lib/svelte/svelte'

  export let entity, category, categoryProperties

  const customProperties = app.user.get('customProperties')

  const { label: categoryLabel } = (propertiesCategories[category] || {})

  let showCategory

  let showAllProperties = categoryLabel == null
  let categoryAllUnsortedProperties = Object.keys(categoryProperties)
  $: categoryCustomProperties = _.intersection(categoryAllUnsortedProperties, customProperties)
  $: notCategoryCustomProperties = _.without(categoryAllUnsortedProperties, ...customProperties)
  $: categoryAllProperties = [ ...categoryCustomProperties, ...notCategoryCustomProperties ]
  $: displayedProperties = showAllProperties ? categoryAllProperties : categoryCustomProperties

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
  $: onChange(displayedProperties, scrollToCategory)
  $: someCustomProperties = _.some(categoryCustomProperties)
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
  <div {id} class="category-properties">
    {#each displayedProperties as property}
      <PropertyClaimsEditor
        bind:entity
        {property}
      />
    {/each}
  </div>
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
    top: -$topbar-height - 10;
  }
  .toggle-custom-properties{
    margin-left: 0.5em;
  }
</style>
