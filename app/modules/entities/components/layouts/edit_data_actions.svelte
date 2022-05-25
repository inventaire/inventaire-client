<script>
  import { i18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import Dropdown from '#components/dropdown.svelte'

  export let entity
  let { uri } = entity

  const edit = async () => app.execute('show:entity:edit', uri)
  const history = async () => app.execute('show:entity:history', uri)
</script>
<!-- TODO: edit wikidata and show deduplicate -->
<div class="menu-wrapper">
  <Dropdown
    align={'right'}
    buttonTitle={i18n('Show actions')}
    >
    <div slot="button-inner">
      {@html icon('cog')}
    </div>
    <ul slot="dropdown-content">
      <li
        class="dropdown-element"
        on:click="{edit}"
      >
        <a href="/entity/{uri}/edit">
          {@html icon('pencil')}
          <span>{i18n('edit bibliographical info')}</span>
        </a>
      </li>
      <li
        class="dropdown-element"
        on:click="{history}"
      >
        <a href="/entity/{uri}/history">
          {@html icon('history')}
          <span>{i18n('view history')}</span>
        </a>
      </li>
    </ul>
  </Dropdown>
</div>
<style lang="scss">
  @import '#general/scss/utils';
  // Dropdown
  .menu-wrapper{
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
