<script>
  import Spinner from '#general/components/spinner.svelte'
  import { I18n, i18n } from '#user/lib/i18n'
  import { hasSelectedLang } from '#entities/components/lib/claims_helpers'
  import { getLangEntities, getPublishersEntities, hasPublisher } from '#entities/components/lib/editions_list_actions_helpers'
  import Flash from '#lib/components/flash.svelte'
  import { onChange } from '#lib/svelte'
  import { icon } from '#lib/handlebars_helpers/icons'
  import { getContext } from 'svelte'

  export let editions,
    hasSomeInitialEditions,
    initialEditions

  const filters = getContext('work-layout:filters-store')

  let flash

  $filters.selectedLang = app.user.lang
  $filters.selectedPublisher = 'all'

  let editionsLangs, langEntitiesLabel
  const waitingForLangEntities = getLangEntities(initialEditions)
    .then(res => ({ editionsLangs, langEntitiesLabel } = res))
    .then(refreshFilters)
    .catch(err => flash = err)

  let publishersUris, publishersLabels, someEditionsHaveNoPublisher
  const waitingForPublishersEntities = getPublishersEntities(initialEditions)
    .then(res => ({ publishersUris, publishersLabels, someEditionsHaveNoPublisher } = res))
    .then(refreshFilters)
    .catch(err => flash = err)

  function refreshFilters () {
    let displayedEntities = initialEditions
    if ($filters.selectedLang !== 'all') {
      displayedEntities = displayedEntities.filter(hasSelectedLang($filters.selectedLang))
    }

    if ($filters.selectedPublisher === 'unknown') {
      displayedEntities = displayedEntities.filter(hasPublisher('unknown'))
    } else if ($filters.selectedPublisher !== 'all') {
      displayedEntities = displayedEntities.filter(hasPublisher($filters.selectedPublisher))
    }

    editions = displayedEntities

    if (langEntitiesLabel) {
      $filters.selectedLangLabel = getLangLabel($filters.selectedLang)
    }
    if (publishersLabels) {
      if ($filters.selectedPublisher === 'unknown') {
        $filters.selectedPublisherLabel = `${I18n('unknown publisher')}`
      } else {
        $filters.selectedPublisherLabel = publishersLabels[$filters.selectedPublisher]
      }
    }
  }

  const langEditionsCount = lang => initialEditions.filter(hasSelectedLang(lang)).length
  const publisherCount = uri => initialEditions.filter(hasPublisher(uri)).length

  const getLangLabel = lang => langEntitiesLabel[lang]?.labels[app.user.lang]

  $: onChange(initialEditions, $filters.selectedLang, $filters.selectedPublisher, refreshFilters)
</script>

{#if hasSomeInitialEditions}
  <div class="filters">
    <span class="filters-header">{i18n('Filter by')}</span>

    {#await waitingForLangEntities}
      <Spinner/>
    {:then}
      {#if editionsLangs.length > 0}
        <div class="filter">
          <label for="language-filter">{I18n('language')}</label>
          <select
            id="language-filter"
            name="language"
            bind:value={$filters.selectedLang}
            class:filtering={$filters.selectedLang !== 'all'}
            >
            <option value="all">{I18n('all languages')} ({initialEditions.length})</option>
            {#each editionsLangs as lang}
              <option value={lang}>{lang} - {getLangLabel(lang)} ({langEditionsCount(lang)})</option>
            {/each}
          </select>
          {#if $filters.selectedLang !== 'all'}
            <button
              title={I18n('reset filter')}
              aria-controls="language-filter"
              on:click={() => $filters.selectedLang = 'all'}
            >{@html icon('close')}</button>
          {/if}
        </div>
      {/if}
    {/await}

    {#await waitingForPublishersEntities}
      <Spinner/>
    {:then}
      {#if publishersUris.length > 0}
        <div class="filter">
          <label for="publisher-filter">{I18n('publisher')}</label>
          <select
            id="publisher-filter"
            name="publisher"
            bind:value={$filters.selectedPublisher}
            class:filtering={$filters.selectedPublisher !== 'all'}
            >
            <option value="all">{I18n('all publishers')} ({initialEditions.length})</option>
            {#each publishersUris as uri}
              <option value={uri}>{publishersLabels[uri]} ({publisherCount(uri)})</option>
            {/each}
            {#if someEditionsHaveNoPublisher}
              <option value="unknown">{I18n('unknown')} ({publisherCount('unknown')})</option>
            {/if}
          </select>
          {#if $filters.selectedPublisher !== 'all'}
            <button
              title={I18n('reset filter')}
              aria-controls="publisher-filter"
              on:click={() => $filters.selectedPublisher = 'all'}
            >{@html icon('close')}</button>
          {/if}
        </div>
      {/if}
    {/await}
  </div>
  <Flash state={flash} />
{/if}

<style lang="scss">
  @import '#general/scss/utils';
  .filters{
    @include display-flex(row, center, flex-start);
    align-self: stretch;
  }
  .filters-header{
    margin: 0.5em;
    align-self: flex-end;
    color: $label-grey;
  }
  .filter{
    margin: 0 1em;
    position: relative;
    select{
      padding-right: 2em;
    }
    button{
      position: absolute;
      right: 0.1em;
      bottom: 0.1em;
      height: 2.1em;
      width: 2em;
      @include bg-hover(white);
      padding: 0;
    }
  }
  select.filtering{
    border-color: $glow;
  }
</style>
