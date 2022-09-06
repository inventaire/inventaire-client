<script>
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import { i18n, I18n } from '#user/lib/i18n'
  import Flash from '#lib/components/flash.svelte'
  import Spinner from '#general/components/spinner.svelte'
  import { getEntitiesByUris } from '#entities/lib/entities'
  import { addSelection, removeSelection } from '#lists/lib/lists'
  import EntityElement from './entity_element.svelte'
  import EntityAutocompleteSelector from '#entities/components/entity_autocomplete_selector.svelte'
  import { createEventDispatcher } from 'svelte'
  const dispatch = createEventDispatcher()

  export let selections, listId, isEditable

  let flash, inputValue = '', showSuggestions
  let entities = []

  const paginationSize = 15
  let offset = paginationSize
  let fetching
  let isAddingSelection
  let windowScrollY = 0
  let listBottomEl

  const getSelectionsEntities = async selections => {
    const uris = selections.map(_.property('uri'))
    return getEntitiesByUris(uris)
  }

  const getInitialSelectionsEntities = async () => {
    const firstSelections = selections.slice(0, paginationSize)
    entities = await getSelectionsEntities(firstSelections)
  }

  const waitingForEntities = getInitialSelectionsEntities()

  const onRemoveSelection = async index => {
    const entity = entities[index]
    removeSelection(listId, entity.uri)
    .then(() => {
      // Enhancement: after remove, have an "undo" button
      entities.splice(index, 1)
      entities = entities
    })
    .catch(err => flash = err)
  }

  const addUriAsSelection = async entity => {
    flash = null
    inputValue = ''
    showSuggestions = false
    isAddingSelection = true
    addSelection(listId, entity.uri)
    .then(selection => {
      if (isNonEmptyArray(selection.alreadyInList)) {
        return flash = {
          type: 'info',
          message: I18n('entity is already in list')
        }
      }
      entities = [ entity, ...entities ]
      dispatch('selectionAdded', { entity, selection })
    })
    .catch(err => flash = err)
    .finally(() => isAddingSelection = false)
  }

  const fetchMore = async () => {
    if (fetching || hasMore === false) return
    fetching = true
    const nextBatchSelections = selections.slice(offset, offset + paginationSize)
    const nextEntities = await getSelectionsEntities(nextBatchSelections)
    if (isNonEmptyArray(nextEntities)) {
      offset += paginationSize
      entities = [ ...entities, ...nextEntities ]
    }
    fetching = false
  }

  $: {
    if (listBottomEl != null && hasMore) {
      const screenBottom = windowScrollY + window.screen.height
      if (screenBottom + 100 > listBottomEl.offsetTop) fetchMore()
    }
  }

  $: hasMore = entities.length >= offset
</script>

<svelte:window bind:scrollY={windowScrollY} />
{#await waitingForEntities}
  <Spinner center={true} />
{:then}
  <section class="entities-list-section">
    {#if isEditable}
      <div class="entities-selector">
        <label for={inputValue}>
          {i18n('Add entity to this list')}
          <!-- Reuse autocomplete selector with the caveat of no edition results possible. -->
          <!-- A more advanced way would be to reuse a Svelte global search bar (not implemented) -->
          <!-- TODO: dont show "no results" at initial state-->
          <EntityAutocompleteSelector
            placeholder={i18n('Search for an entity')}
            autofocus={false}
            bind:currentEntityLabel={inputValue}
            bind:showSuggestions
            on:select={e => addUriAsSelection(e.detail)}
          />
        </label>
        <Flash bind:state={flash}/>
      </div>
    {/if}

    <ul class="list-selections">
      {#if isAddingSelection}
        <li class="loading">{I18n('loading')}<Spinner/></li>
      {/if}
      {#each entities as entity, index (entity.uri)}
        <li class="list-selection">
          <EntityElement
            {entity}
          />
          {#if isEditable}
            <div class="status">
              <button
                class="tiny-button"
                on:click={() => onRemoveSelection(index)}
              >
                {i18n('remove')}
              </button>
            </div>
          {/if}
        </li>
      {:else}
        {i18n('nothing here')}
      {/each}
    </ul>
    {#if hasMore}
      <p bind:this={listBottomEl}>
        {I18n('loading')}
        <Spinner/>
      </p>
    {/if}
  </section>
{/await}

<style lang="scss">
  @import '#general/scss/utils';
  .entities-list-section{
    flex: 1;
    align-self: center;
    @include display-flex(column, center);
    width: 100%;
    padding: 0 1em;

  }
  .tiny-button{ padding: 0.5em; }
  .list-selections{
    @include display-flex(column, center);
    @include radius;
    width: 100%;
    margin: 1em 0;
    background-color: white;
  }
  .list-selection{
    @include display-flex(row, center);
    padding: 0 1em;
    width: 100%;
    border-bottom: 1px solid $light-grey;
    &:hover{
      background-color: $off-white;
    }
  }
  .entities-selector{
    width:100%
  }
  .status{
    @include display-flex(row, center, center);
    white-space: nowrap;
  }
  /*Large (>40em) screens*/
  @media screen and (min-width: 40em) {
    .entities-list-section{
      width: 40em;
    }
  }
  /*Small screens*/
  @media screen and (max-width: $small-screen) {
    .entities-list-section{
      padding: 0;
    }
  }
  /*Very small screens*/
  @media screen and (max-width: $very-small-screen) {
    .list-selection{
      @include display-flex(column, flex-start);
    }
  }
</style>
