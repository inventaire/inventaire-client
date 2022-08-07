<script>
  import { i18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  export let list

  let { name, description, creator } = list

  // TODO: rebase and fix visibility once items/shelves visibility branches have been merged
  // let { visibility } = list
  // const listings = app.user.listings()
  // let visibilityData = listings[visibility]

  let isEditable = creator === app.user.id

  const showEditor = async () => {
    const { default: ListEditor } = await import('#modules/lists/components/list_editor.svelte')
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
</script>

<div class="list-info">
  <div class="data">
    <h3>{name}</h3>
    <p class="visibility">
      <!-- {@html icon(visibilityData.icon)} {visibilityData.label} -->
      {'<visibility>'}
    </p>
    <p>{description}</p>
  </div>
  <div class="actions">
    {#if isEditable}
      <button
        class="tiny-button light-blue"
        on:click={showEditor}
      >
        {@html icon('pencil')}
        {i18n('Edit list info')}
      </button>
    {/if}
  </div>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .list-info{
    align-self: stretch;
    margin: 0.5em;
    padding: 0.5em;
    @include radius;
    @include display-flex(row);
    background-color: $light-grey;
  }
  .actions{
    margin: 1em;
    margin-left: auto;
  }
  button{
    // padding: 0.5em;
    white-space: nowrap;
    line-height: 1.6em;
    // width: 10em;
  }
</style>
