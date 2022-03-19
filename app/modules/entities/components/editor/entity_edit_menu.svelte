<script>
  import { i18n, I18n } from '#user/lib/i18n'
  import Dropdown from '#components/dropdown.svelte'
  import { icon } from '#lib/handlebars_helpers/icons'
  import Link from '#lib/components/link.svelte'
  import { getWikidataUrl } from '#entities/lib/entities'

  export let entity

  const { uri } = entity

  const wikidataUrl = getWikidataUrl(uri)
</script>

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
            text={I18n('see_on_website', { website: 'wikidata.org' })}
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


<style lang="scss">
  @import '#general/scss/utils';
  .menu-wrapper{
    /*Large screens*/
    @media screen and (min-width: $smaller-screen) {
      position: absolute;
      right: 0;
    }
    :global(.dropdown-button){
      @include big-button($grey);
    }
    button, :global(a){
      font-weight: normal;
      padding: 0.5rem;
      :global(.fa){
        font-size: 1.4rem;
      }
    }
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
