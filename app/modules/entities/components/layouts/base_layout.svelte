<script>
  import { I18n } from '#user/lib/i18n'
  import { buildAltUri } from '../lib/entities'
  import preq from '#lib/preq'
  import { icon } from '#lib/utils'
  import Dropdown from '#components/dropdown.svelte'
  import { getWikidataUrl } from '#entities/lib/entities'
  import Link from '#lib/components/link.svelte'
  import { icon as iconFn } from '#lib/handlebars_helpers/icons'
  import Flash from '#lib/components/flash.svelte'

  export let entity, flash

  let showDropdown

  const { uri, _id, type } = entity

  const refreshEntity = async () => {
    const { entities } = await preq.get(app.API.entities.getByUris(uri, true))
    entity = Object.values(entities)[0]
    // Let other components now that a refresh was requested
    entity.refreshTimestamp = Date.now()
  }

  const altUri = buildAltUri(uri, _id)

  const wikidataUrl = getWikidataUrl(uri)

  const edit = async () => app.execute('show:entity:edit', uri)
  const history = async () => app.execute('show:entity:history', uri)
</script>

<div class="layout">
  <div class="header-wrapper">
    <div class="header">
      <h2 class="type">{I18n(type)}</h2>
    </div>
    <div class="edit-data-actions">
      <Dropdown
        align={'right'}
        buttonTitle={I18n('Show actions')}
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
              text={I18n('edit bibliographical info')}
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
              {@html iconFn('refresh')}
              {I18n('refresh Wikidata data')}
            </li>
          {/if}
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
        </ul>
      </Dropdown>
    </div>
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
  .edit-data-actions{
    /*Small screens*/
    @media screen and (max-width: $smaller-screen) {
      margin-right: 0.5em;
    }
    /*Large screens*/
    @media screen and (min-width: $smaller-screen) {
      right: 0;
    }
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
    margin-bottom: 2em;
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
      padding: 0;
    }
  }
</style>
