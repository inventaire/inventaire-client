<script>
  import { I18n } from '#user/lib/i18n'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import ClaimsInfobox from './claims_infobox.svelte'
  export let entity, works, standalone

  const { uri, image, label } = entity
  let { claims } = entity

  }

  const claimsOrder = [
    ...editionWorkProperties,
    'wdt:P2679', // author of foreword
    'wdt:P2680', // author of afterword
    'wdt:P655', // translator
    'wdt:P577', // date of publication
    'wdt:P1104', // number of pages
    'wdt:P123', // publisher
    'wdt:P212', // isbn 13
    'wdt:P957', // isbn 10
    'wdt:P407', // language
    'wdt:P629', // work
    'wdt:P195', // collection
    'wdt:P2635', // number of volumes
    'wdt:P856', // official website
  ]

  $: app.navigate(`/entity/${uri}`)
</script>
{#if standalone}
  <h3 class="layout-type-label">{I18n(entity.type)}</h3>
{/if}
<div class="edition-data-wrapper">
  <div class="edition-data">
    {#if image.url}
      <div class="cover">
        <img src="{imgSrc(image.url, 300)}" alt="{label}">
      </div>
    {/if}
    <div class="claims entity-data-box">
      <h2 class="edition-title">{entity.claims['wdt:P1476']}</h2>
      <ClaimsInfobox {claims} {claimsOrder}/>
      <!-- TODO: 'entities:edit_data' -->
    </div>
  </div>
  <div class="editionEntityActions"></div>
  <!-- TODO: entities:items_lists -->
</div>
<!-- TODO: works list -->

<style lang="scss">
  @import '#general/scss/utils';
  .layout-type-label{
    margin: 0.5em;
  }
</style>
