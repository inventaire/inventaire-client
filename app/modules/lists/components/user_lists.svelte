<script>
  import ListCreator from '#modules/lists/components/list_creator.svelte'
  import { getListsByCreator, serializeList } from '#modules/lists/lib/lists'
  import { i18n, I18n } from '#user/lib/i18n'
  import { loadInternalLink } from '#lib/utils'
  import Flash from '#lib/components/flash.svelte'
  import Spinner from '#components/spinner.svelte'

  export let user

  let lists, flash

  const waitingForLists = getListsByCreator(user._id)
    .then(res => lists = Object.values(res.lists).map(serializeList))
    .catch(err => flash = err)

  const isMainUser = user._id === app.user.id
  let newList = {}

  $: if (newList._id) {
    lists = lists.concat([ serializeList(newList) ])
    newList = {}
  }
</script>

<div class="lists-layout">
  <h3 class="subheader">{I18n('lists')}</h3>

  {#await waitingForLists}
    <Spinner />
  {:then}
    <ul>
      {#each lists as list}
        <li>
          <a href={list.pathname} on:click={loadInternalLink}>
            {list.name}
          </a>
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
        <ListCreator bind:list={newList} />
      </div>
    {/if}
  {/await}

  <Flash state={flash} />
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
  li a{
    display: block;
    @include bg-hover(darken($light-grey, 5%));
    padding: 0.5em;
    margin: 0.2em;
    @include radius;
  }
  .empty{
    color: $grey;
    text-align: center;
  }
  .menu{
    margin-top: 1em;
    @include display-flex(row, center, flex-end);
  }
</style>
