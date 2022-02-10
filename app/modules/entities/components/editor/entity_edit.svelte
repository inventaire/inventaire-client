<script>
  import { I18n } from 'modules/user/lib/i18n'
  import LabelsEditor from './labels_editor.svelte'
  import propertiesPerType from 'modules/entities/lib/editor/properties_per_type'
  import PropertyClaimsEditor from './property_claims_editor.svelte'
  import getBestLangValue from 'modules/entities/lib/get_best_lang_value'
  import { loadInteralLink } from 'lib/utils'

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
  <h2>
    <a href="/entity/{uri}" on:click={loadInteralLink}>
      {favoriteLabel || title}
    </a>
  </h2>
  <p class="type">{I18n(entity.type)}</p>
  <p class="uri">{uri}</p>

  {#if !hasMonolingualTitle}
    <LabelsEditor {entity} bind:favoriteLabel {favoriteLabelLang} />
  {/if}

  {#each Object.keys(typeProperties) as property}
    <PropertyClaimsEditor
      {entity}
      {property}
      {typeProperties}
    />
  {/each}
</div>

<style lang="scss">
  @import 'app/modules/general/scss/utils';
  .entity-edit{
    @include display-flex(column, center, center);
    max-width: 50em;
    margin: 0 auto;
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
</style>
