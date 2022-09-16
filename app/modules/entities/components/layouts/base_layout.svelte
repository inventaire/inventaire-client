<script>
  import { i18n, I18n } from '#user/lib/i18n'
  import { buildAltUri } from '../lib/entities'
  import preq from '#lib/preq'
  import { icon, loadInternalLink } from '#lib/utils'
  import Dropdown from '#components/dropdown.svelte'
  import { getWikidataUrl, getWikidataHistoryUrl } from '#entities/lib/entities'
  import Link from '#lib/components/link.svelte'
  import { icon as iconFn } from '#lib/handlebars_helpers/icons'
  import Flash from '#lib/components/flash.svelte'
  import { entityTypeNameBySingularType } from '#entities/lib/types/entities_types'
  import { screen } from '#lib/components/stores/screen'
  import Spinner from '#general/components/spinner.svelte'

  export let entity, flash

  let showDropdown, waitForEntityRefresh

  const { uri, _id, type } = entity

  const refreshEntity = async () => {
    waitForEntityRefresh = preq.get(app.API.entities.getByUris(uri, true))
    const { entities } = await waitForEntityRefresh
    entity = Object.values(entities)[0]
    // Let other components now that a refresh was requested
    entity.refreshTimestamp = Date.now()
  }

  const altUri = buildAltUri(uri, _id)

  const wikidataUrl = getWikidataUrl(uri)
  const wikidataHistoryUrl = getWikidataHistoryUrl(uri)

  const edit = async () => app.execute('show:entity:edit', uri)
  const history = async () => app.execute('show:entity:history', uri)
</script>

<div class="layout">
  <div class="header-wrapper">
    <div class="header">
      <h2 class="type">{I18n(entityTypeNameBySingularType[type])}</h2>
    </div>
    {#if $screen.isLargerThan('$small-screen')}
      <ul class="large-screen-actions">
        <li>
          <a
            class="action"
            href={`/entity/${uri}/edit`}
            on:click={loadInternalLink}
            title={i18n('Edit bibliographical info')}
          >
            {@html iconFn('pencil')}
          </a>
        </li>
        {#if wikidataUrl}
          <li>
            <a
              class="action"
              target='_blank'
              rel='noopener'
              href={wikidataUrl}
              title={I18n('see_on_website', { website: 'wikidata.org' })}
            >
              {@html iconFn('wikidata')}
            </a>
          </li>
          <li
          >
            <div
              on:click={refreshEntity}
              class="action"
              title={I18n('refresh Wikidata data')}
            >
              {#await waitForEntityRefresh}
                <Spinner />
              {:then}
                {@html iconFn('refresh')}
              {/await}
            </div>
          </li>
          <li>
            <a
              class="action"
              target='_blank'
              rel='noopener'
              href={wikidataHistoryUrl}
              title={i18n('Entity history')}
            >
              {@html iconFn('history')}
            </a>
          </li>
        {:else}
          <li>
            <a
              class="action"
              href={`/entity/${uri}/history`}
              on:click={loadInternalLink}
              title={i18n('Entity history')}
            >
              {@html iconFn('history')}
            </a>
          </li>
        {/if}
      </ul>
    {:else}
      <div class="small-screen-actions">
        <Dropdown
          align={'right'}
          buttonTitle={i18n('Show actions')}
          bind:showDropdown={showDropdown}
          >
          <div slot="button-inner">
            {@html icon('cog')}
          </div>
          <ul slot="dropdown-content">
            <li
              class="dropdown-element"
              on:click={edit}
            >
              <Link
                url={`/entity/${uri}/edit`}
                text={i18n('Edit bibliographical info')}
                icon='pencil'
              />
            </li>
            {#if wikidataUrl}
              <li class="dropdown-element">
                <Link
                  url={wikidataUrl}
                  text={I18n('see_on_website', { website: 'wikidata.org' })}
                  icon='wikidata'
                />
              </li>
              <li
                class="dropdown-element"
                on:click={refreshEntity}
                on:click={() => { showDropdown = false }}
              >
                {#await waitForEntityRefresh}
                  <Spinner />
                {:then}
                  {@html iconFn('refresh')}
                {/await}
                {I18n('refresh Wikidata data')}
              </li>
              <li
                class="dropdown-element"
                on:click={history}
              >
                <Link
                  url={wikidataHistoryUrl}
                  text={I18n('entity history')}
                  icon='history'
                />
              </li>
            {:else}
              <li
                class="dropdown-element"
                on:click={history}
              >
                <Link
                  url={`/entity/${uri}/history`}
                  text={I18n('entity history')}
                  icon='history'
                />
              </li>
            {/if}
          </ul>
        </Dropdown>
      </div>
    {/if}
  </div>
  <div class="entity-wrapper">
    <slot name="entity" />
  </div>
  <Flash state={flash} />
  <div class="entity-data-wrapper">
    <p class="uri">
      {I18n(type)}
      - {uri}
      {#if altUri}
         - {altUri}
      {/if}
    </p>
  </div>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .large-screen-actions{
    @include display-flex(row, flex-end);
    .action{
      @include display-flex(row, center);
      @include tiny-button($off-white);
      height: 1.5em;
      cursor: pointer;
      padding: 1.2em 1em;
      margin: 0.5em;
      :global(.fa){
        color: grey;
        font-size: 1.4rem;
      }
    }
  }
  .small-screen-actions{
    right: 0;
    @include display-flex(column, flex-end);
    :global(.dropdown-button){
      @include tiny-button($grey);
      padding: 0.5em;
    }
  }
  [slot="dropdown-content"]{
    @include shy-border;
    background-color:white;
    @include radius;
    // z-index known cases: items map
    z-index: 1;
    position: relative;
    li{
      @include bg-hover(white, 10%);
      @include display-flex(row, center, flex-start);
      min-height: 3em;
      cursor:pointer;
      padding: 0 1em;
      &:not(:last-child){
        margin-bottom: 0.2em;
      }
      :global(.error){
        flex: 1;
      }
    }
  }
  .layout{
    @include display-flex(column, stretch, center);
    margin: 0 auto;
    max-width: 84em;
    padding: 0 1em;
    background-color: white;
  }
  .type{
    color: $grey;
    font-size: 1.1rem;
    @include sans-serif;
  }
  .header-wrapper{
    display: flex;
    margin: 1em 0;
  }
  .header{
    @include display-flex(row, center, center);
    width: 100%;
  }
  .entity-wrapper{
    @include display-flex(column, flex-start);
  }
  .entity-data-wrapper{
    @include display-flex(column, center);
  }
  /*Large screens*/
  @media screen and (min-width: $small-screen) {
    .header-wrapper{
      margin-left: 1.2em;
    }
  }
  /*Small screens*/
  @media screen and (max-width: $small-screen) {
    .header-wrapper{
      @include display-flex(row, center, space-between);
    }
    .entity-wrapper{
      @include display-flex(column, flex-start);
    }
  }
  /*Very Small screens*/
  @media screen and (max-width: $very-small-screen) {
    .layout{
      padding: 0 0.5em;
    }
  }
</style>
