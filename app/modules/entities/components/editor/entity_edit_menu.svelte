<script>
  import { i18n, I18n } from '#user/lib/i18n'
  import Dropdown from '#components/dropdown.svelte'
  import { icon } from '#lib/handlebars_helpers/icons'
  import Link from '#lib/components/link.svelte'
  import { getWikidataUrl } from '#entities/lib/entities'
  import { checkWikidataMoveabilityStatus, moveToWikidata } from '#entities/lib/move_to_wikidata'
  import Flash from '#lib/components/flash.svelte'
  import preq from '#lib/preq'

  export let entity

  let flash
  const { uri, invUri, label, history } = entity
  const { hasDataadminAccess } = app.user
  const wikidataUrl = getWikidataUrl(uri)
  const { ok: canBeMovedToWikidata, reason: moveabilityStatus } = checkWikidataMoveabilityStatus(entity)
  const canBeDeleted = invUri != null

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

  function reportDataError (e) {
    app.execute('show:feedback:menu', {
      subject: `[${uri}][${I18n('data error')}] `,
      uris: [ uri ],
      event: e
    })
  }

  function deleteEntity () {
    app.execute('ask:confirmation', {
      confirmationText: I18n('delete_entity_confirmation', { label }),
      action: _deleteEntity
    })
  }

  async function _deleteEntity () {
    try {
      await preq.post(app.API.entities.delete, { uris: [ invUri ] })
      app.execute('show:entity:edit', uri)
    } catch (err) {
      // TODO: recover displayDeteEntityErrorContext feature to show rich error message
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
      {#if wikidataUrl}
        <li>
          <Link
            url={wikidataUrl}
            text={I18n('see_on_website', { website: 'wikidata.org' })}
            icon='wikidata'
          />
        </li>
      {/if}
      <li>
        <Link
          url={history}
          text={i18n('Open entity history')}
          icon='history'
        />
      </li>
      {#if hasDataadminAccess}
        <li>
          <Link
            url='/entity/merge?from={uri}'
            text={I18n('merge')}
            icon='compress'
          />
        </li>
        {#if canBeDeleted}
          <li>
            <button
              title={I18n('delete entity')}
              on:click={deleteEntity}
              >
                {@html icon('trash')}
                {I18n('delete')}
            </button>
          </li>
        {/if}
      {/if}
      {#if canBeMovedToWikidata}
        <li>
          <button
            title={moveabilityStatus}
            on:click={_moveToWikidata}
            >
            {@html icon('wikidata')}
            {I18n('move to Wikidata')}
          </button>
        </li>
      {/if}
      <li>
        <button
          title={I18n('report_an_error_in_entity_data')}
          on:click={reportDataError}
          >
            {@html icon('flag')}
            {I18n('report an error')}
        </button>
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
    /*Small screens*/
    @media screen and (max-width: $smaller-screen) {
      margin-right: 0.5em;
    }
    /*Large screens*/
    @media screen and (min-width: $smaller-screen) {
      position: absolute;
      right: 0;
      top: 1.4em;
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
      @include display-flex(row, stretch);
      min-height: 3em;
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
      flex: 1;
      @include display-flex(row, center, flex-start);
      text-align: left;
      @include bg-hover(white, 5%);
      padding: 0.5em;
      :global(.fa){
        margin-right: 0.5em;
      }
    }
  }
</style>
