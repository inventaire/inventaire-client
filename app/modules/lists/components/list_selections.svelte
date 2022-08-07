<script>
  import { icon } from '#lib/utils'
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import { i18n, I18n } from '#user/lib/i18n'
  import Flash from '#lib/components/flash.svelte'
  import { addSelection, removeSelection } from '#lists/lib/lists'
  import EntityElement from './entity_element.svelte'
  import EntityAutocompleteSelector from '#entities/components/entity_autocomplete_selector.svelte'
  import { createEventDispatcher } from 'svelte'
  const dispatch = createEventDispatcher()

  export let entities, listId, isEditable
  let showSelectionSelector, flash

  const onRemoveSelection = async index => {
    const entity = entities[index]
    return removeSelection(listId, entity.uri)
    .then(() => {
      // Enhancement: after remove, have an "undo" button
      entities.splice(index, 1)
      entities = entities
    })
    .catch(err => flash = err)
  }

  const addUriAsSelection = async entity => {
    flash = null
    return addSelection(listId, entity.uri)
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
  }
</script>

<section class="entities-list-section">
  {#if isEditable}
    {#if showSelectionSelector}
      <div class="entities-selector">
        <label for={entities}>
          {I18n('search for entities to add to the list')}
        </label>
        <!-- Reuse autocomplete selector with the caveat of no edition results possible. -->
        <!-- A more advanced way would be to reuse a Svelte global search bar (not implemented) -->
        <!-- TODO: dont show "no results" at initial state-->
        <EntityAutocompleteSelector
          on:select={e => addUriAsSelection(e.detail)}
        />
        <Flash bind:state={flash}/>
      </div>
    {:else}
      <button
        id="show-selection-selector"
        class="tiny-button"
        on:click={() => showSelectionSelector = true}
      >
        {@html icon('plus')}
        {I18n('add entities')}
      </button>
    {/if}
  {/if}
  <div class="entities-list">
    {#each entities as entity, index (entity.uri)}
      <li class="entity-element">
        <EntityElement
          {entity}
        />
        <div class="status">
          <button
            class="tiny-button soft-grey remove"
            on:click={() => onRemoveSelection(index)}
          >
            {i18n('remove')}
          </button>
        </div>
      </li>
    {/each}
  </div>
</section>

<style lang="scss">
  @import '#general/scss/utils';
  .entities-list-section{
    @include display-flex(column, center);
  }
  .entities-list{
    width: 100%;
    padding: 0 1em;
    margin: 1em 0;
  }
  .entity-element{
    @include display-flex(row, center, space-between);
    padding: 1em 0;
    border-bottom: 1px solid $light-grey
  }
  .entities-selector{
    width:100%
  }
  .remove{
    margin-left: 1em;
  }
  .status{
    @include display-flex(row, center, center);
    white-space: nowrap;
  }
  #show-selection-selector{
    width: 10em;
    padding: 0.3em;
  }
  /*Large (>40em) screens*/
  @media screen and (min-width: 40em) {
    .entities-list-section{
      width: 40em;
    }
  }
  /*Very small screens*/
  @media screen and (max-width: $very-small-screen) {
    .entity-element{
      @include display-flex(column, flex-start);
    }
    .remove{
      margin: 0.5em 0;
    }
  }
</style>
