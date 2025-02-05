<script lang="ts">
  import { createEventDispatcher } from 'svelte'
  import { partition, without } from 'underscore'
  import { isPositiveIntegerString } from '#app/lib/boolean_tests'
  import { autofocus } from '#app/lib/components/actions/autofocus'
  import Flash from '#app/lib/components/flash.svelte'
  import { newError } from '#app/lib/error'
  import { icon } from '#app/lib/icons'
  import { getActionKey } from '#app/lib/key_events'
  import log_ from '#app/lib/loggers'
  import { onChange } from '#app/lib/svelte/svelte'
  import { loadInternalLink } from '#app/lib/utils'
  import type { EntityDraft } from '#app/types/entity'
  import Spinner from '#components/spinner.svelte'
  import { createEntity } from '#entities/lib/create_entity'
  import { addClaim, getWorkEditions, type SerializedEntity } from '#entities/lib/entities'
  import { getSerieOrWorkExtendedAuthorsUris } from '#entities/lib/types/serie_alt'
  import type { SeriePartPlaceholder } from '#entities/views/cleanup/lib/fill_gaps'
  import { mergeEntities } from '#entities/views/editor/lib/merge_entities'
  import type { EntityValue } from '#server/types/entity'
  import { i18n, I18n } from '#user/lib/i18n'
  import { getDefaultWorkP31FromSerie } from '../lib/claims_helpers'
  import LanguageSelector from './language_selector.svelte'
  import { sortByLabel, workIsPlaceholder, type WorkWithEditions } from './lib/serie_cleanup_helpers'
  import SerieCleanupAuthor from './serie_cleanup_author.svelte'
  import SerieCleanupEdition from './serie_cleanup_edition.svelte'
  import WorkPicker from './work_picker.svelte'
  import type { WikimediaLanguageCode } from 'wikibase-sdk'

  export let work: WorkWithEditions | SeriePartPlaceholder
  export let serie: SerializedEntity
  export let possibleOrdinals: number[]
  export let showAuthors: boolean
  export let showEditions: boolean
  export let showDescriptions: boolean
  export let largeMode: boolean
  export let placeholderTitle: string = null
  export let allSerieAuthors: SerializedEntity[]
  export let allSerieParts: WorkWithEditions[]
  export let selectedLang: WikimediaLanguageCode = null
  export let nextPlaceholderOrdinalToCreate: number = null

  const { label, serieOrdinalNum } = work
  let description, pathname, editPathname
  let nonPlaceholderWork: WorkWithEditions
  let isPlaceholder = false
  if (workIsPlaceholder(work)) {
    ;({ isPlaceholder } = work)
  } else {
    ;({ description, pathname, editPathname } = work)
    nonPlaceholderWork = work
  }

  const currentWorkAuthorsUris = new Set(getSerieOrWorkExtendedAuthorsUris(work))
  let [ currentWorkAuthors, authorsSuggestions ] = partition(allSerieAuthors, author => currentWorkAuthorsUris.has(author.uri))

  let showMergeWorkPicker = false
  let showPlaceholderEditor = false

  const dispatch = createEventDispatcher()

  let merging, flash
  async function merge (selectedWork: WorkWithEditions) {
    try {
      merging = true
      await mergeEntities(nonPlaceholderWork.uri, selectedWork.uri)
      dispatch('merged', { from: nonPlaceholderWork, to: selectedWork })
    } catch (err) {
      merging = false
      flash = err
    }
  }

  async function addAuthor (author: SerializedEntity) {
    try {
      currentWorkAuthors = [ ...currentWorkAuthors, author ]
      authorsSuggestions = without(authorsSuggestions, author)
      // TODO: add support for other author roles properties
      await addClaim(nonPlaceholderWork, 'wdt:P50', author.uri as EntityValue)
    } catch (err) {
      flash = err
    }
  }

  async function selectOrdinal (e) {
    const ordinal = e.currentTarget.value
    if (!isPositiveIntegerString(ordinal)) return
    try {
      work = nonPlaceholderWork = await addClaim(nonPlaceholderWork, 'wdt:P1545', ordinal)
      dispatch('selectOrdinal', nonPlaceholderWork)
    } catch (err) {
      flash = err
    }
  }

  let placeholderLabel = placeholderTitle
  let creatingPlaceholder
  async function createPlaceholder () {
    try {
      creatingPlaceholder = true
      const entity: EntityDraft = {
        labels: { [selectedLang]: placeholderLabel },
        claims: {
          'wdt:P31': [ getDefaultWorkP31FromSerie(serie) ],
          'wdt:P179': [ serie.uri as EntityValue ],
          'wdt:P1545': [ serieOrdinalNum.toString() as `${number}` ],
        },
      }
      const createdWork = await createEntity(entity)
      dispatch('createdPlaceholder', createdWork)
    } catch (err) {
      flash = err
    } finally {
      creatingPlaceholder = false
    }
  }

  function onInputKeyDown (e) {
    const key = getActionKey(e)
    if (key === 'esc') showPlaceholderEditor = false
  }

  $: onChange(placeholderTitle, () => {
    if (!showPlaceholderEditor) placeholderLabel = placeholderTitle
  })

  function onNextPlaceholderOrdinalToCreateChange () {
    if (nextPlaceholderOrdinalToCreate != null && !creatingPlaceholder && nextPlaceholderOrdinalToCreate === work.serieOrdinalNum) {
      if (workIsPlaceholder(work)) {
        createPlaceholder()
      } else {
        const err = newError('work was already created', 500, { work })
        log_.error(err, 'work was already created')
      }
    }
  }

  $: onChange(nextPlaceholderOrdinalToCreate, onNextPlaceholderOrdinalToCreateChange)

  async function getEditions () {
    const allEditions = await getWorkEditions(nonPlaceholderWork.uri, { refresh: true })
    // Filter-out composite editions as it would be a mess to handle the work picker
    // with several existing work claims
    nonPlaceholderWork.editions = allEditions.filter(edition => edition.claims['wdt:P629'].length === 1)
  }
  const waitForEditions = !isPlaceholder ? getEditions() : null

  function changeEditionWork (edition: SerializedEntity, targetWork: WorkWithEditions) {
    dispatch('changeEditionWork', { edition, originWork: nonPlaceholderWork, targetWork })
  }
</script>

<li class="serie-cleanup-work" class:placeholder={isPlaceholder} class:large={largeMode}>
  <div class="head">
    {#if serieOrdinalNum != null}
      <span class="serie-ordinal-num">{serieOrdinalNum}</span>
    {:else}
      <select class="ordinal-selector glowing" on:change={selectOrdinal}>
        <option value="">--</option>
        {#each possibleOrdinals as num}
          <option value={num}>{num}</option>
        {/each}
      </select>
    {/if}
    {#if isPlaceholder}
      {#if creatingPlaceholder}
        <Spinner center={true} />
      {:else if showPlaceholderEditor}
        <div class="placeholder-editor">
          <div class="placeholder-label-editor">
            <LanguageSelector bind:selectedLang />
            <input
              type="text"
              bind:value={placeholderLabel}
              on:keydown={onInputKeyDown}
              use:autofocus
            />
          </div>
          <button class="create tiny-success-button" on:click={createPlaceholder}>{I18n('create')}</button>
        </div>
      {:else}
        <button class="show-placeholder-editor" on:click={() => showPlaceholderEditor = true}>
          <span class="label">{placeholderLabel}</span>
          <span class="creation-call">{i18n('create')}</span>
        </button>
      {/if}
    {:else}
      <a class="show-entity link" href={pathname} on:click={loadInternalLink}>
        <span class="label">{label}</span>
        {#if showDescriptions && description}
          <span class="description">{description}</span>
        {/if}
      </a>
      <a
        href={editPathname}
        class="show-entity-edit pencil"
        title={i18n('edit data')}
        on:click={loadInternalLink}
      >
        {@html icon('pencil')}
      </a>
      <button
        class="toggle-merge-work-picker"
        title={I18n('merge')}
        on:click={() => showMergeWorkPicker = !showMergeWorkPicker}
      >
        {@html icon('compress')}
      </button>
    {/if}
  </div>
  {#if merging}
    <Spinner center={true} />
  {:else if showMergeWorkPicker}
    <WorkPicker
      work={nonPlaceholderWork}
      {allSerieParts}
      validateLabel="merge"
      on:selectWork={e => merge(e.detail)}
      on:close={() => showMergeWorkPicker = false}
    />
  {/if}
  {#if !isPlaceholder && showAuthors}
    <div class="authors-container">
      <ul class="current-authors">
        {#each currentWorkAuthors as author (author.uri)}
          <SerieCleanupAuthor {author} isSuggestion={false} />
        {/each}
      </ul>
      <ul class="authors-suggestions">
        {#each authorsSuggestions as author (author.uri)}
          <SerieCleanupAuthor {author} isSuggestion={true} on:add={() => addAuthor(author)} />
        {/each}
      </ul>
    </div>
  {/if}
  {#if !isPlaceholder && showEditions}
    {#await waitForEditions}
      <Spinner center={true} />
    {:then}
      <div class="editions-container">
        <ul>
          <!-- Keeping a consistent sorting function so that rolling back an edition -->
          <!-- puts it back at the same spot -->
          {#each nonPlaceholderWork.editions.sort(sortByLabel) as edition}
            <SerieCleanupEdition
              {edition}
              work={nonPlaceholderWork}
              {allSerieParts}
              {largeMode}
              on:changeEditionWork={e => changeEditionWork(edition, e.detail)}
            />
          {/each}
        </ul>
      </div>
    {/await}
  {/if}

  <Flash state={flash} />
</li>

<style lang="scss">
  @import '#general/scss/utils';
  .serie-cleanup-work{
    margin: 0.5em;
    padding: 0.5em;
    width: 22em;
    background-color: $light-grey;
    @include radius;
    .head{
      @include display-flex(row, center);
    }
    &.placeholder{
      @include bg-hover(#bbb);
      cursor: pointer;
    }
    .ordinal-selector{
      max-width: 4em;
      margin-inline-end: 0.5em;
    }
    .serie-ordinal-num{
      font-size: 1.2em;
      color: $grey;
      font-weight: bold;
      @include serif;
      padding-inline-end: 1em;
    }
    .show-entity{
      .label, .description{
        display: block;
        line-height: 1.3em;
      }
      .description{
        color: $grey;
      }
    }
    .pencil :global(.fa){
      @include shy;
    }
    .show-entity-edit{
      margin-inline-start: auto;
    }
    .show-placeholder-editor{
      flex: 1;
      @include display-flex(row, center, space-between);
    }
    .creation-call{
      background-color: #666;
      color: white;
      @include radius;
      padding: 0 0.4em;
      margin-inline-start: auto;
      min-width: 5em;
      text-align: center;
    }
    .authors-container, .editions-container{
      max-height: 20em;
      overflow: auto;
    }
    .authors-container, .editions-container ul:not(:empty){
      margin: 1em 0;
    }
    .placeholder-label-editor{
      @include display-flex(row, baseline, center);
      margin-block-end: 0.5em;
      :global(select){
        width: 6em;
        padding: 0.1em;
      }
      input{
        margin: 0;
      }
    }
  }
  .toggle-merge-work-picker{
    @include shy;
  }
  .large{
    width: 25em;
    .authors-container, .editions-container{
      max-height: 60em;
    }
  }
</style>
