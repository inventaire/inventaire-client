<script>
  import { i18n, I18n } from '#user/lib/i18n'
  import Dropdown from '#components/dropdown.svelte'
  import { icon } from '#lib/handlebars_helpers/icons'
  import Link from '#lib/components/link.svelte'
  import { getWikidataUrl } from '#entities/lib/entities'
  import { checkWikidataMoveabilityStatus, moveToWikidata } from '#entities/lib/move_to_wikidata'
  import Flash from '#lib/components/flash.svelte'

  export let entity

  let flash

  const { uri } = entity

  const wikidataUrl = getWikidataUrl(uri)

  const { ok: canBeMovedToWikidata, reason: moveabilityStatus } = checkWikidataMoveabilityStatus(entity)

  async function _moveToWikidata () {
    try {
      if (!app.user.hasWikidataOauthTokens()) {
        return app.execute('show:wikidata:edit:intro:modal', this.model)
      }
      await moveToWikidata(uri)
      // This should now redirect us to the new Wikidata edit page
      app.execute('show:entity:edit', uri)
    } catch (err) {
      flash = err
    }
  }
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
            disabled={!canBeMovedToWikidata}
            title={moveabilityStatus}
            on:click={_moveToWikidata}
            >
            {@html icon('wikidata-colored')}
            {I18n('move to Wikidata')}
          </button>
        {/if}
      </li>
      {#if flash}
        <li>
          <Flash bind:state={flash} />
        </li>
      {/if}
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
      padding: 0.8rem;
    }
  }
  [slot="button-inner"]{
    :global(.fa){
      font-size: 1.2rem;
    }
  }
  [slot="dropdown-content"]{
    @include shy-border;
    background-color: white;
    @include radius;
    min-width: 14em;
    li{
      @include display-flex(row);
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
      :global(.error){
        flex: 1;
      }
    }
    button, :global(a){
      font-weight: normal;
      padding: 0.5rem;
      :global(.fa){
        font-size: 1.4rem;
      }
    }
  }
</style>
