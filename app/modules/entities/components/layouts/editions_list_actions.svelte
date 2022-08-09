<script>
  import Spinner from '#general/components/spinner.svelte'
  import { I18n, i18n } from '#user/lib/i18n'
  import { hasSelectedLang } from '#entities/components/lib/claims_helpers'
  import { getLangEntities, getPublishersEntities, hasPublisher } from '#entities/components/lib/editions_list_actions_helpers'
  import Flash from '#lib/components/flash.svelte'
  import { onChange } from '#lib/svelte'
  import { icon } from '#lib/handlebars_helpers/icons'

  export let editions,
    hasSomeInitialEditions,
    initialEditions

  let flash
  let userLang = app.user.lang
  let selectedLang = userLang
  let selectedPublisher = 'all'

  let editionsLangs, langEntitiesLabel
  const waitingForLangEntities = getLangEntities(initialEditions)
    .then(res => ({ editionsLangs, langEntitiesLabel } = res))
    .catch(err => flash = err)

  let publishersUris, publishersLabels, someEditionsHaveNoPublisher
  const waitingForPublishersEntities = getPublishersEntities(initialEditions)
    .then(res => ({ publishersUris, publishersLabels, someEditionsHaveNoPublisher } = res))
    .catch(err => flash = err)

  const refreshFilters = () => {
    let displayedEntities = initialEditions
    if (selectedLang !== 'all') {
      displayedEntities = displayedEntities.filter(hasSelectedLang(selectedLang))
    }

    if (selectedPublisher === 'unknown') {
      displayedEntities = displayedEntities.filter(hasPublisher('unknown'))
    } else if (selectedPublisher !== 'all') {
      displayedEntities = displayedEntities.filter(hasPublisher(selectedPublisher))
    }

    editions = displayedEntities
  }

  const langEditionsCount = lang => initialEditions.filter(hasSelectedLang(lang)).length
  const publisherCount = uri => initialEditions.filter(hasPublisher(uri)).length

  const getLangLabel = lang => langEntitiesLabel[lang]?.labels[app.user.lang]

  $: onChange(initialEditions, selectedLang, selectedPublisher, refreshFilters)
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
          <select id="language-filter" name="language" bind:value={selectedLang}>
            <option value="all">{I18n('all languages')} ({initialEditions.length})</option>
            {#each editionsLangs as lang}
              <option value={lang}>{lang} - {getLangLabel(lang)} ({langEditionsCount(lang)})</option>
            {/each}
          </select>
          {#if selectedLang !== 'all'}
            <button
              title={I18n('reset filter')}
              aria-controls="language-filter"
              on:click={() => selectedLang = 'all'}
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
          <select id="publisher-filter" name="publisher" bind:value={selectedPublisher}>
            <option value="all">{I18n('all publishers')} ({initialEditions.length})</option>
            {#each publishersUris as uri}
              <option value={uri}>{publishersLabels[uri]} ({publisherCount(uri)})</option>
            {/each}
            {#if someEditionsHaveNoPublisher}
              <option value="unknown">{I18n('unknown')} ({publisherCount('unknown')})</option>
            {/if}
          </select>
          {#if selectedPublisher !== 'all'}
            <button
              title={I18n('reset filter')}
              aria-controls="publisher-filter"
              on:click={() => selectedPublisher = 'all'}
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
</style>
