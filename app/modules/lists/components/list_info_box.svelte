<script>
  import { i18n } from '#user/lib/i18n'
  import { icon, loadInternalLink } from '#lib/utils'
  import preq from '#lib/preq'

  export let list, isEditable

  let { name, description, creator: creatorId } = list
  let creator = {}

  // TODO: rebase and fix visibility once items/shelves visibility branches have been merged
  // let { visibility } = list
  // const listings = app.user.listings()
  // let visibilityData = listings[visibility]

  const getCreatorUsername = async () => {
    if (isEditable) return creator = app.user.toJSON()
    creator = await getUserById(creatorId)
  }

  const getUserById = id => preq.get(app.API.users.byIds([ id ])).then(({ users }) => users[id])

  const waitingForCreator = getCreatorUsername()

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
    // todo: garbage collect event listener with onDestroy
  }

  $: name = list.name
  $: description = list.description
</script>

<div
  class="list-info"
  class:isNotEditable={!isEditable}
>
  <div class="data">
    <h3>{name}</h3>
    <!-- <p class="visibility"> -->
    <!--  {@html icon(visibilityData.icon)} {visibilityData.label} -->
    <!-- </p> -->
    {#if description}
      <p>{description}</p>
    {/if}
    {#await waitingForCreator then}
      <div class="creatorRow">
        <label for='listCreator'>
          {i18n('creator')}:
        </label>
        <a
          id="listCreator"
          href="/inventory/{creator.username}"
          on:click={loadInternalLink}
        >
          {creator.username}
        </a>
      </div>
    {/await}
  </div>
  {#if isEditable}
    <div class="actions">
      <button
        class="tiny-button light-blue"
        on:click={showEditor}
      >
        {@html icon('pencil')}
        {i18n('Edit list info')}
      </button>
    </div>
  {/if}
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
  .isNotEditable{
    align-self: center;
    background-color: unset;
  }
  .creatorRow{
    @include display-flex(row);
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
  a:hover{
    text-decoration: underline;

  }
</style>
