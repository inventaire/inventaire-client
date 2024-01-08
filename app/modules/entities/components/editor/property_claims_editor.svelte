<script>
  import { propertiesEditorsConfigs } from '#entities/lib/properties'
  import { propertiesPerType } from '#entities/lib/editor/properties_per_type'
  import ClaimEditor from './claim_editor.svelte'
  import { icon } from '#lib/utils'
  import { i18n, I18n } from '#user/lib/i18n'
  import { slide } from 'svelte/transition'
  import assert_ from '#lib/assert_types'
  import { getPropertyClaimsCount, isEmptyClaimValue, isNonEmptyClaimValue } from '#entities/components/editor/lib/editors_helpers'
  import Flash from '#lib/components/flash.svelte'
  import { isWikidataPropertyUri } from '#lib/boolean_tests'
  import { getWikidataPropertyDocumentationUrl } from '#lib/wikimedia/wikidata'

  export let entity, property, required = false

  entity.claims[property] = entity.claims[property] || []

  let flash
  const { type } = entity
  assert_.string(type)
  const typeProperties = propertiesPerType[type]
  const { customLabel } = typeProperties[property]
  const { multivalue, datatype } = propertiesEditorsConfigs[property]
  const fixed = datatype.split('-')[0] === 'fixed'
  const propertyClaimsCanBeShown = !(fixed && entity.claims[property].length === 0)

  function addBlankValue () {
    flash = null
    removeBlankValue()
    entity.claims[property] = [ ...entity.claims[property], null ]
  }

  function removeBlankValue () {
    entity.claims[property] = entity.claims[property].filter(isNonEmptyClaimValue)
  }

  function setValue (i, value) {
    if (isNonEmptyClaimValue(value) && entity.claims[property].includes(value) && entity.claims[property].indexOf(value) !== i) {
      flash = {
        type: 'error',
        message: I18n('this value is already used')
      }
      value = null
    }
    entity.claims[property][i] = value
    if (value === null) removeBlankValue()
  }

  let canAddValue
  $: {
    if (isEmptyClaimValue(entity.claims[property]?.slice(-1)[0])) {
      canAddValue = false
    } else {
      canAddValue = (multivalue || getPropertyClaimsCount(entity.claims[property]) === 0)
    }
  }

  $: isRequiredAndMissing = required && getPropertyClaimsCount(entity.claims[property]) === 0
</script>

{#if entity.claims[property] && propertyClaimsCanBeShown}
  <li
    class="editor-section"
    class:fixed
    class:missing-required={isRequiredAndMissing}
    transition:slide={{ duration: 100 }}
  >
    {#if isRequiredAndMissing}
      <span class="required-notice">{I18n('required')}</span>
    {/if}
    <div class="property-info">
      <h3 class="editor-section-header">{I18n(customLabel || property)}</h3>
      {#if isWikidataPropertyUri(property)}
        <a
          class="uri"
          href={getWikidataPropertyDocumentationUrl(property)}
          target="_blank"
          rel="noreferrer"
        >
          {property}
        </a>
      {:else}
        <span class="uri">{property}</span>
      {/if}
    </div>
    <div class="property-claim-values">
      <!-- Do not set the #each element (key) to prevent descarding claim_editor components on value change
           as that would make the "undo" impossible -->
      {#each entity.claims[property] as value, i}
        <ClaimEditor
          bind:entity
          {property}
          {value}
          index={i}
          on:set={e => setValue(i, e.detail)}
        />
      {/each}
      <Flash bind:state={flash} />
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
  </li>
{/if}

<style lang="scss">
  @import "#entities/scss/entity_editors_commons";
  .editor-section-header{
    inline-size: 9em;
    margin-block-end: 0;
  }
  .property-claim-values{
    flex: 1 1 auto;
    max-inline-size: 100%;
  }
  .add-value{
    block-size: 2em;
    font-weight: normal;
    @include display-flex(row, center, space-between);
    &:first-child{
      margin-block-start: 0.2em;
    }
    &:not(:first-child){
      margin-block-start: 1em;
    }
  }
  .fixed{
    background-color: $dark-grey;
    &, .editor-section-header{
      color: white;
    }
  }
  .editor-section{
    position: relative;
    // add transition for both border and margin
    @include transition(all);
  }
  .required-notice{
    position: absolute;
    inset-block-end: 100%;
    color: $lighten-primary-color;
    inset-inline-start: 0;
    font-size: 0.9rem;
    line-height: 1.2rem;
    @include radius;
  }
  .missing-required{
    border: 1px solid $lighten-primary-color;
    // Make room for the .required-notice
    margin-block-start: 1em;
  }
</style>
