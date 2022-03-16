<script>
  import { i18n, I18n } from '#user/lib/i18n'
  import LabelsEditor from './labels_editor.svelte'
  import propertiesPerType from '#entities/lib/editor/properties_per_type'
  import PropertyClaimsEditor from './property_claims_editor.svelte'
  import getBestLangValue from '#entities/lib/get_best_lang_value'
  import { loadInteralLink } from '#lib/utils'
  import Dropdown from '#components/dropdown.svelte'
  import { icon } from '#lib/handlebars_helpers/icons'
  import Link from '#lib/components/link.svelte'
  import { getWikidataUrl } from '#entities/lib/entities'

  export let entity

  const { uri, type, labels } = entity
  const typeProperties = propertiesPerType[type]
  const hasMonolingualTitle = typeProperties['wdt:P1476'] != null
  const title = hasMonolingualTitle ? entity.claims['wdt:P1476']?.[0] : null
  let {
    value: favoriteLabel,
    lang: favoriteLabelLang,
  } = getBestLangValue(app.user.lang, null, labels)

  const wikidataUrl = getWikidataUrl(uri)
</script>

<div class="entity-edit">
  <div class="header">
    <h2>
      <a href="/entity/{uri}" on:click={loadInteralLink}>
        {favoriteLabel || title}
      </a>
    </h2>
    <p class="type">{I18n(entity.type)}</p>
    <p class="uri">{uri}</p>

    <div class="menu-wrapper">
      <Dropdown
        alignRight={true}
        buttonTitle={i18n('Show actions')}
        >
        <div slot="button-inner">
          {@html icon('cog')}
        </div>
        <ul slot="dropdown-content">
          <li>
            {#if wikidataUrl}
              <Link
                url={wikidataUrl}
                text={i18n('see_on_website', { website: 'wikidata.org' })}
                icon='wikidata-colored'
              />
            {:else}
              <button
                title="{I18n('this entity is ready to be imported to Wikidata')}"
                >
                {@html icon('wikidata-colored')}
                {I18n('move to Wikidata')}
              </button>
            {/if}
          </li>
        </ul>
      </Dropdown>
    </div>
  </div>

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
  @import '#general/scss/utils';
  .entity-edit{
    @include display-flex(column, stretch, center);
    max-width: 50em;
    margin: 0 auto;
  }
  .header{
    position: relative;
    @include display-flex(column, center, center);
    button{
      padding: 0.5rem;
      :global(.fa){
        font-size: 1.4rem;
      }
    }
  }
  .menu-wrapper{
    /*Large screens*/
    @media screen and (min-width: $smaller-screen) {
      position: absolute;
      right: 0;
    }
    :global(.dropdown-button){
      @include big-button($grey);
    }
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
  button{
    font-weight: normal;
  }
  [slot="dropdown-content"]{
    @include shy-border;
    background-color: white;
    @include radius;
    min-width: 14em;
    li{
      flex: 1;
      @include display-flex(row, center, flex-start);
      button{
        flex: 1;
        @include display-flex(row, center, flex-start);
        text-align: left;
        @include bg-hover(white, 5%);
        padding: 0.5em;
      }
      &:not(:last-child){
        margin-bottom: 0.2em;
      }
    }
  }
</style>
