<script>
  import { I18n } from '#user/lib/i18n'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  export let entity, standalone
  const { uri, image, label } = entity

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
      <!-- TODO: <EntityClaims {entity}/> -->
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
