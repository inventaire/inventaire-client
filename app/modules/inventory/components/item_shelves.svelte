<script>
  import { i18n, I18n } from '#user/lib/i18n'
  import { icon, loadInternalLink } from '#lib/utils'
  import Spinner from '#components/spinner.svelte'
  import { getShelvesByOwner, getByIds as getShelvesByIds } from '#shelves/lib/shelves'
  import ShelfInfo from '#inventory/components/shelf_info.svelte'
  import { onChange } from '#lib/svelte/svelte'
  import { debounce, isEqual } from 'underscore'

  export let serializedItem

  const { _id: itemId, mainUserIsOwner } = serializedItem
  let { shelves: shelvesIds } = serializedItem
  let userShelves = [], itemShelves = []
  let hideUnselectedShelves = false

  let waitForShelves
  if (mainUserIsOwner) {
    waitForShelves = getShelvesByOwner(app.user.id)
      .then(res => userShelves = res)
  } else {
    waitForShelves = getShelvesByIds(shelvesIds)
      .then(res => {
        itemShelves = Object.values(res)
      })
  }

  let selectedShelves, displayedShelves
  const updateDisplayedShelves = () => {
    selectedShelves = userShelves.filter(shelf => shelvesIds.includes(shelf._id))
    displayedShelves = hideUnselectedShelves ? selectedShelves : userShelves
  }
  $: onChange(hideUnselectedShelves, shelvesIds, userShelves, updateDisplayedShelves)

  let currentShelves = shelvesIds
  async function save () {
    if (isEqual(shelvesIds, currentShelves)) return
    currentShelves = shelvesIds
    await app.request('items:update', {
      items: [ itemId ],
      attribute: 'shelves',
      value: shelvesIds,
    })
  }

  const lazySave = debounce(save, 500)

  $: onChange(shelvesIds, lazySave)
</script>

<div class="item-shelves">
  {#if mainUserIsOwner}
    {#await waitForShelves}
      <Spinner /><span class="section-label">{I18n('shelves')}</span>
    {:then}
      {#if userShelves.length > 0}
        <span class="section-label">{I18n('shelves')}</span>
        <div class="shelves-options">
          {#each displayedShelves as shelf (shelf._id)}
            <label title={I18n('select_shelf')}>
              <input type="checkbox" bind:group={shelvesIds} value={shelf._id} />
              <ShelfInfo bind:shelf />
            </label>
          {/each}
        </div>
        {#if selectedShelves.length < userShelves.length}
          <button
            on:click={e => hideUnselectedShelves = !hideUnselectedShelves}
            title={hideUnselectedShelves ? i18n('Show other shelves') : i18n('Hide non-selected shelves')}
            class:rotate={!hideUnselectedShelves}
          >
            {@html icon('chevron-down')}
          </button>
        {/if}
      {/if}
    {/await}
  {:else}
    {#if itemShelves?.length > 0}
      <span class="section-label">{I18n('shelves')}</span>
      <ul>
        {#each itemShelves as shelf}
          <li>
            <a
              href={`/shelves/${shelf._id}`}
              on:click|stopPropagation={loadInternalLink}
            >
              <ShelfInfo {shelf} />
            </a>
          </li>
        {/each}
      </ul>
    {/if}
  {/if}
</div>

<style lang="scss">
  @import '#general/scss/utils';
  @import '#inventory/scss/shelves_selectors';
  .item-shelves:not(:empty){
    margin-top: 1em;
    background: $off-white;
    padding: 0.5em 0;
    @include radius;
    @include display-flex(column, stretch);
  }
  .section-label{
    padding: 0 0.5em;
    margin-bottom: 0.2em;
  }
  .shelves-options, ul{
    max-height: 16em;
    overflow-y: auto;
    overflow-x: hidden;
  }
  button{
    padding: 0.5em;
    @include bg-hover($off-white, 5%);
    @include display-flex(row, center, center);
    :global(.fa){
      @include transition(transform, 0.2s);
    }
  }
  .rotate{
    :global(.fa){
      transform: scaleY(-1);
    }
  }
</style>
