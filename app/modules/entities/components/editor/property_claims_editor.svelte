<script>
  import properties from 'modules/entities/lib/properties'
  import ClaimEditor from './claim_editor.svelte'
  import { icon } from 'lib/utils'
  import { i18n, I18n } from 'modules/user/lib/i18n'

  export let entity, property, typeProperties

  let propertyClaims = entity.claims[property] || []

  const { customLabel } = typeProperties[property]
  const { multivalue } = properties[property]

  function addBlankValue () {
    propertyClaims = propertyClaims || []
    propertyClaims.push(null)
  }

  function removeBlankValue () {
    propertyClaims = propertyClaims.filter(value => value != null)
  }

  function setValue (property, i, value) {
    propertyClaims[i] = value
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

<div class="editor-section">
  <h3 class="editor-section-header">{I18n(customLabel || property)}</h3>
  <div class="property-claim-values">
    {#each propertyClaims as value, i}
      <ClaimEditor
        {entity} {property} {value}
        on:remove={removeBlankValue}
        on:set={e => setValue(property, i, e.detail)}
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
  @import 'app/modules/entities/scss/entity_editors_commons';
  .editor-section{
    @include display-flex(row);
  }
  .editor-section-header{
    width: 9em;
  }
  .property-claim-values{
    flex: 1;
  }
  .add-value{
    height: 2em;
    font-weight: normal;
    @include display-flex(row, center, space-between);
    &:first-child{
      margin: 0.5em 0;
    }
  }
</style>
