<script>
  import properties from '#entities/lib/properties'
  import propertiesPerType from '#entities/lib/editor/properties_per_type'
  import ClaimEditor from './claim_editor.svelte'
  import { icon } from '#lib/utils'
  import { i18n, I18n } from '#user/lib/i18n'
  import { slide } from 'svelte/transition'
  import assert_ from '#lib/assert_types'
  import { getPropertyClaimsCount, isEmptyClaimValue, isNonEmptyClaimValue } from '#entities/components/lib/editors_helpers'
  import Flash from '#lib/components/flash.svelte'

  export let entity, property, required = false

  let propertyClaims = entity.claims[property] || []
  $: entity.claims[property] = propertyClaims

  let flash
  const { type } = entity
  assert_.string(type)
  const typeProperties = propertiesPerType[type]
  const { customLabel } = typeProperties[property]
  const { multivalue, editorType } = properties[property]
  const fixed = editorType.split('-')[0] === 'fixed'

  function addBlankValue () {
    removeBlankValue()
    propertyClaims = [ ...propertyClaims, null ]
  }

  function removeBlankValue () {
    propertyClaims = propertyClaims.filter(isNonEmptyClaimValue)
  }

  function setValue (i, value) {
    if (propertyClaims.includes(value) && propertyClaims.indexOf(value) !== i) {
      flash = {
        type: 'error',
        message: I18n('this value is already used')
      }
      value = null
    }
    propertyClaims[i] = value
    if (value === null) removeBlankValue()
  }

  let canAddValue
  $: {
    if (isEmptyClaimValue(propertyClaims.at(-1))) {
      canAddValue = false
    } else {
      canAddValue = (multivalue || getPropertyClaimsCount(propertyClaims) === 0)
    }
  }
</script>

<div
  class="editor-section"
  class:fixed
  class:missing-required={required && getPropertyClaimsCount(propertyClaims) === 0}
  transition:slide
  >
  <h3 class="editor-section-header">{I18n(customLabel || property)}</h3>
  <div class="property-claim-values">
    {#each propertyClaims as value, i}
      <ClaimEditor
        {entity} {property} {value}
        on:set={e => setValue(i, e.detail)}
      />
    {/each}
    <Flash bind:state={flash}/>
    {#if canAddValue}
      <button
        class="add-value tiny-button soft-grey"
        on:click={addBlankValue}
      >
        {@html icon('plus')}
        <span>{i18n('add')}</span>
      </button>
    {/if}
  </div>
</div>

<style lang="scss">
  @import '#entities/scss/entity_editors_commons';
  .editor-section-header{
    width: 9em;
  }
  .property-claim-values{
    flex: 1 1 auto;
    max-width: 100%;
  }
  .add-value{
    height: 2em;
    font-weight: normal;
    @include display-flex(row, center, space-between);
    &:first-child{
      margin-top: 0.2em;
    }
    &:not(:first-child){
      margin-top: 1em;
    }
  }
  .fixed{
    background-color: $dark-grey;
    &, .editor-section-header{
      color: white;
    }
  }
  .editor-section{
    @include transition(border);
  }
  .missing-required{
    border: 1px solid lighten($primary-color, 30%);
  }
</style>
