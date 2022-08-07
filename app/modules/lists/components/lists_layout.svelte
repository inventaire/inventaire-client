<script>
  import { icon } from '#lib/handlebars_helpers/icons'
  import ListCreator from '#modules/lists/components/list_creator.svelte'
  import { i18n, I18n } from '#user/lib/i18n'
  export let lists, user

  const isMainUser = user._id === app.user.id
  let showCreateForm, newList = {}

  $: if (newList._id) {
    lists = lists.concat([ newList ])
    newList = null
    showCreateForm = false
  }
</script>

<div class="lists-layout">
  <h3 class="subheader">{I18n('lists')}</h3>

  <ul>
    {#each lists as list}
      <li>
        {list.name}
      </li>
    {/each}
    {#if lists.length === 0}
      <li class="empty">
        {i18n('There is nothing here')}
      </li>
    {/if}
  </ul>

  {#if isMainUser}
    <div class="menu">
      {#if showCreateForm}
        <ListCreator bind:list={newList} />
      {:else}
        <button
          on:click={() => showCreateForm = true}
          class="tiny-button light-blue"
          >
          {@html icon('plus')}
          {i18n('Create a new list')}
        </button>
      {/if}
    </div>
  {/if}
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .lists-layout{
    background-color: $light-grey;
    margin: 1em;
    padding: 0.5em;
  }
  h3{
    font-size: 1rem;
    @include sans-serif;
  }
  .empty{
    color: $grey;
    text-align: center;
  }
  .menu{
    margin-top: 1em;
    @include display-flex(row, center, flex-end);
  }
  .tiny-button{
    padding: 0.5em;
  }
</style>
