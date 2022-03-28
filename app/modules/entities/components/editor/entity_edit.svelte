<script>
  import { I18n } from '#user/lib/i18n'
  import LabelsEditor from './labels_editor.svelte'
  import propertiesPerType from '#entities/lib/editor/properties_per_type'
  import PropertyClaimsEditor from './property_claims_editor.svelte'
  import getBestLangValue from '#entities/lib/get_best_lang_value'
  import { loadInteralLink } from '#lib/utils'
  import EntityEditMenu from './entity_edit_menu.svelte'

  export let entity

  const { uri, type, labels } = entity
  const typeProperties = propertiesPerType[type]
  const hasMonolingualTitle = typeProperties['wdt:P1476'] != null
  const title = hasMonolingualTitle ? entity.claims['wdt:P1476']?.[0] : null
  let {
    value: favoriteLabel,
    lang: favoriteLabelLang,
  } = getBestLangValue(app.user.lang, null, labels)
</script>

<div class="entity-edit">
  <div class="header">
    <div class="header-main">
      <h2>
        <a href="/entity/{uri}" on:click={loadInteralLink}>
          {favoriteLabel || title}
        </a>
      </h2>
      <p class="type">{I18n(entity.type)}</p>
      <p class="uri">{uri}</p>
    </div>

    <EntityEditMenu {entity} />
  </div>

  {#if !hasMonolingualTitle}
    <LabelsEditor {entity} bind:favoriteLabel {favoriteLabelLang} />
  {/if}

  {#each Object.keys(typeProperties) as property}
    <PropertyClaimsEditor
      {entity}
      {property}
    />
  {/each}
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .entity-edit{
    @include display-flex(column, stretch, center);
    max-width: 50em;
    margin: 0 auto;
  }
  .header{
    position: relative;
  }
  h2{
    margin-bottom: 0;
    a{
      @include link-dark;
    }
  }
  .type{
    color: $grey;
    font-size: 1rem;
  }
  .uri{
    @include sans-serif;
    font-size: 0.8rem;
  }
  /*Small screens*/
  @media screen and (max-width: $small-screen) {
    .header{
      @include display-flex(row, center, space-between, wrap);
    }
    .header-main{
      margin: 0 0.5em;
    }
  }
  /*Large screens*/
  @media screen and (min-width: $small-screen) {
    .header-main{
      @include display-flex(column, center, center);
    }
  }
</style>
