<script>
  import properties from 'modules/entities/lib/properties'
  import propertiesPerType from 'modules/entities/lib/editor/properties_per_type'
  import ClaimEditor from './claim_editor.svelte'
  import { icon } from 'lib/utils'
  import { i18n, I18n } from 'modules/user/lib/i18n'
  export let entity

  const { type, claims } = entity

  const typeProperties = propertiesPerType[type]

  function canAddValue (propertyClaims = [], property) {
    if (propertyClaims.at(-1) === null) return false
    return (properties[property].multivalue || propertyClaims.length === 0)
  }

  function addBlankValue (property) {
    claims[property] = claims[property] || []
    claims[property].push(null)
  }

  function removeBlankValue (property) {
    claims[property] = claims[property].filter(value => value != null)
  }
</script>

{#each Object.keys(typeProperties) as property}
  <div class="editor-section">
    <h3 class="editor-section-header">{I18n(typeProperties.customLabel || property)}</h3>
    <div class="property-claim-values">
      {#if claims[property]}
        {#each claims[property] as value}
          <ClaimEditor
            {entity} {property} {value}
            on:remove={() => removeBlankValue(property)}
          />
        {/each}
      {/if}
      {#if canAddValue(claims[property], property)}
        <button
          class="add-value tiny-button soft-grey"
          on:click={() => addBlankValue(property)}
        >
          {@html icon('plus')}
          <span>{i18n('add')}</span>
        </button>
      {/if}
    </div>
  </div>
{/each}

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
  }
</style>
