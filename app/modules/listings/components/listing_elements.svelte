<script>
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import { i18n, I18n } from '#user/lib/i18n'
  import Flash from '#lib/components/flash.svelte'
  import Spinner from '#general/components/spinner.svelte'
  import { getEntitiesByUris } from '#entities/lib/entities'
  import { addElement, removeElement } from '#listings/lib/listings'
  import EntityElement from './entity_element.svelte'
  import EntityAutocompleteSelector from '#entities/components/entity_autocomplete_selector.svelte'
  import { createEventDispatcher } from 'svelte'
  const dispatch = createEventDispatcher()

  export let elements, listingId, isEditable

  let flash, inputValue = '', showSuggestions
  let entities = []

  const paginationSize = 15
  let offset = paginationSize
  let fetching
  let isAddingElement
  let windowScrollY = 0
  let listingBottomEl

  const getElementsEntities = async elements => {
    const uris = elements.map(_.property('uri'))
    return getEntitiesByUris(uris)
  }

  const getInitialElementsEntities = async () => {
    const firstElements = elements.slice(0, paginationSize)
    entities = await getElementsEntities(firstElements)
  }

  const waitingForEntities = getInitialElementsEntities()

  const onRemoveElement = async index => {
    const entity = entities[index]
    removeElement(listingId, entity.uri)
    .then(() => {
      // Enhancement: after remove, have an "undo" button
      entities.splice(index, 1)
      entities = entities
    })
    .catch(err => flash = err)
  }

  const addUriAsElement = async entity => {
    flash = null
    inputValue = ''
    showSuggestions = false
    isAddingElement = true
    addElement(listingId, entity.uri)
    .then(element => {
      if (isNonEmptyArray(element.alreadyInList)) {
        return flash = {
          type: 'info',
          message: I18n('entity is already in list')
        }
      }
      entities = [ entity, ...entities ]
      dispatch('elementAdded', { entity, element })
    })
    .catch(err => flash = err)
    .finally(() => isAddingElement = false)
  }

  const fetchMore = async () => {
    if (fetching || hasMore === false) return
    fetching = true
    const nextBatchElements = elements.slice(offset, offset + paginationSize)
    const nextEntities = await getElementsEntities(nextBatchElements)
    if (isNonEmptyArray(nextEntities)) {
      offset += paginationSize
      entities = [ ...entities, ...nextEntities ]
    }
    fetching = false
  }

  $: {
    if (listingBottomEl != null && hasMore) {
      const screenBottom = windowScrollY + window.screen.height
      if (screenBottom + 100 > listingBottomEl.offsetTop) fetchMore()
    }
  }

  $: hasMore = entities.length >= offset
</script>

<svelte:window bind:scrollY={windowScrollY} />
{#await waitingForEntities}
  <Spinner center={true} />
{:then}
  <section class="entities-listing-section">
    {#if isEditable}
      <div class="entities-selector">
        <label for={inputValue}>
          {i18n('Add a work to this list')}
          <EntityAutocompleteSelector
            searchTypes={'works'}
            placeholder={i18n('Search for an entity')}
            autofocus={false}
            bind:currentEntityLabel={inputValue}
            bind:showSuggestions
            on:select={e => addUriAsElement(e.detail)}
          />
        </label>
        <Flash bind:state={flash}/>
      </div>
    {/if}

    <ul class="listing-elements">
      {#if isAddingElement}
        <li class="loading">{I18n('loading')}<Spinner/></li>
      {/if}
      {#each entities as entity, index (entity.uri)}
        <li class="listing-element">
          <EntityElement
            {entity}
          />
          {#if isEditable}
            <div class="status">
              <button
                class="tiny-button"
                on:click={() => onRemoveElement(index)}
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
      <p bind:this={listingBottomEl}>
        {I18n('loading')}
        <Spinner/>
      </p>
    {/if}
  </section>
{/await}

<style lang="scss">
  @import '#general/scss/utils';
  .entities-listing-section{
    flex: 1;
    align-self: center;
    @include display-flex(column, center);
    width: 100%;
    padding: 0 1em;

  }
  .tiny-button{ padding: 0.5em; }
  .listing-elements{
    @include display-flex(column, center);
    @include radius;
    width: 100%;
    margin: 1em 0;
    background-color: white;
  }
  .listing-element{
    @include display-flex(row, center);
    padding: 0 1em;
    width: 100%;
    border-bottom: 1px solid $light-grey;
    &:hover{
      background-color: $off-white;
    }
  }
  .entities-selector{
    width: 100%;
    padding: 0 0.5em;
  }
  label{
    cursor:auto;
  }
  .status{
    @include display-flex(row, center, center);
    white-space: nowrap;
  }
  /*Large (>40em) screens*/
  @media screen and (min-width: 40em) {
    .entities-listing-section{
      width: 40em;
    }
  }
  /*Small screens*/
  @media screen and (max-width: $small-screen) {
    .entities-listing-section{
      padding: 0;
    }
  }
  /*Very small screens*/
  @media screen and (max-width: $very-small-screen) {
    .listing-element{
      @include display-flex(column, flex-start);
    }
  }
</style>
