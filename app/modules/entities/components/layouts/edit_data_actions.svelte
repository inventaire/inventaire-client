<script>
  import { createEventDispatcher } from 'svelte'
  import { I18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import Dropdown from '#components/dropdown.svelte'
  import { getWikidataUrl } from '#entities/lib/entities'
  import Link from '#lib/components/link.svelte'
  import { icon as iconFn } from '#lib/handlebars_helpers/icons'

  export let entity

  const dispatch = createEventDispatcher()

  let { uri } = entity
  const wikidataUrl = getWikidataUrl(uri)

  const edit = async () => app.execute('show:entity:edit', uri)
  const history = async () => app.execute('show:entity:history', uri)
  const refreshEntity = () => dispatch('refreshEntity')
</script>
<!-- TODO: edit wikidata and show deduplicate -->
<div class="edit-data-actions">
  <Dropdown
    align={'right'}
    buttonTitle={I18n('Show actions')}
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
          text={I18n('view history')}
          icon='history'
        />
      </li>
    </ul>
  </Dropdown>
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
</style>
