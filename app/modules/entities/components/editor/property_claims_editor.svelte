<script>
  import properties from '#entities/lib/properties'
  import ClaimEditor from './claim_editor.svelte'
  import { icon } from '#lib/utils'
  import { i18n, I18n } from '#user/lib/i18n'

  export let entity, property, typeProperties

  let propertyClaims = entity.claims[property] || []

  const { customLabel } = typeProperties[property]
  const { multivalue, editorType } = properties[property]
  const fixed = editorType.split('-')[0] === 'fixed'

  function addBlankValue () {
    propertyClaims = propertyClaims || []
    propertyClaims.push(null)
  }

  function removeBlankValue () {
    propertyClaims = propertyClaims.filter(value => value != null)
  }

  function setValue (i, value) {
    propertyClaims[i] = value
    if (value == null) removeBlankValue()
  }

  let canAddValue
  $: {
    if (propertyClaims.at(-1) === null) {
      canAddValue = false
    } else {
      canAddValue = (multivalue || propertyClaims.length === 0)
    }
  }
</script>

<div class="editor-section" class:fixed>
  <h3 class="editor-section-header">{I18n(customLabel || property)}</h3>
  <div class="property-claim-values">
    {#each propertyClaims as value, i}
      <ClaimEditor
        {entity} {property} {value}
        on:set={e => setValue(i, e.detail)}
      />
    {/each}
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
</style>
