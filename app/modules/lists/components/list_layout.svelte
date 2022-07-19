<script>
  import { I18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import ListSelectionsCandidate from './list_selections_candidate.svelte'
  export let list

  let { _id, name, description, visibility, creator, selections } = list

  const listings = app.user.listings()
  let visibilityData = listings[visibility]
  let isEditable = creator === app.user.id

  const showEditor = async () => {
    const { default: ListEditor } = await import('#lists/components/list_editor.svelte')
    app.execute('modal:open')
    const component = app.layout.showChildComponent('modal', ListEditor, {
      props: {
        list,
      }
    })
    component.$on('listUpdated', event => {
      list = event.detail.list
    })
  }

  $: name = list.name
  $: description = list.description
</script>
<div class="header">
  <p>{I18n('list')}</p>
  <h3>{name}</h3>
  <p class="visibility">
    <!-- placeholder before finer privacy settings implemented -->
    <!-- {@html icon(visibilityData.icon)} {visibilityData.label} -->
    {visibilityData || ''}
  </p>
  <p>{description}</p>
  {#if isEditable}
    <button
      id="showListEditor"
      class="tiny-button"
      on:click={showEditor}
    >
      {@html icon('pencil')}
      {I18n('edit info')}
    </button>
  {/if}
  <ListSelectionsCandidate
    bind:selections
    listId={_id}
    {isEditable}
  />
</div>
<div class="footer">
  <p class="list-id">
    {I18n('list')}
      -
    {_id}
  </p>
</div>
<style lang="scss">
  @import '#general/scss/utils';
  .header{
    @include display-flex(column, center, center);
    display: flex;
    margin: 1em 0;
    width: 100%;
  }
  .visibility{
    color: #666;
  }
  .list-id{
    @include display-flex(column, center);
    font-size: small;
  }
  #showListEditor{
    margin: 1em 0;
    padding: 0.5em;
    white-space: nowrap;
    width: 10em;
  }
</style>
