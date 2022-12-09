<script>
  import Spinner from '#components/spinner.svelte'
  import { getTextDirection } from '#lib/active_languages'
  import Flash from '#lib/components/flash.svelte'
  import Link from '#lib/components/link.svelte'
  import languagesData from '#assets/js/languages_data'
  import preq from '#lib/preq'
  import { onChange } from '#lib/svelte/svelte'
  import { expired } from '#lib/utils'
  import { i18n } from '#user/lib/i18n'
  import { indexBy, partition } from 'underscore'

  export let entity

  const { uri } = entity

  let summaryData, summaries, highlightedSummaries, otherSummaries, summeriesPerKey, flash, selectedSummary
  let waitingForSummariesData, waitingForText

  const { lang: userLang } = app.user
  const langLabel = languagesData[userLang].native

  function getSummaries () {
    const refresh = entity.refreshTimestamp && !expired(entity.refreshTimestamp, 1000)
    if (summaries == null || refresh) {
      waitingForSummariesData = preq.get(app.API.data.summaries({ uri, langs: userLang, refresh }))
        .then(res => {
          summaries = sortWikipediaSummaryFirst(res.summaries)
          summeriesPerKey = indexBy(summaries, 'key')

          if (!selectedSummary) {
            [ highlightedSummaries, otherSummaries ] = partition(summaries, isHighlightedSummary)
            const bestOption = highlightedSummaries[0] || otherSummaries[0]
            if (bestOption) selectedSummary = bestOption.key
          }
        })
        .catch(err => flash = err)
    }
  }

  const sortWikipediaSummaryFirst = summaries => {
    return summaries.sort((a, b) => {
      if (a.key.includes('wiki')) return -1
      if (b.key.includes('wiki')) return 1
      return a.key > b.key
    })
  }

  const isHighlightedSummary = summary => summary.lang === userLang

  // This will trigger the first call to getSummaries, and further calls when the entity changes
  $: onChange(entity, getSummaries)

  function getSummaryText ({ key, lang, sitelink }) {
    const { title } = sitelink
    waitingForText = preq.get(app.API.data.wikipediaExtract(lang, title))
      .then(res => {
        summeriesPerKey[key].text = res.extract
        // Force refresh
        summaryData = summeriesPerKey[selectedSummary]
      })
      .catch(err => flash = err)
  }

  function getText () {
    if (summeriesPerKey) {
      summaryData = summeriesPerKey[selectedSummary]
      if (!summaryData.text) getSummaryText(summaryData)
    }
  }
  $: onChange(selectedSummary, getText)
  $: splitOptions = highlightedSummaries?.length > 0 && otherSummaries?.length > 0
</script>

<div class="summary" class:has-summary={summaries?.length > 0}>
  {#await waitingForSummariesData then}
    {#if summaries.length > 0}
      <!-- The label 'summary' is not adapted to human or publisher entities -->
      <!-- Maybe the text doesn't need a label, has a summary/presentation text is kind of what one would expect to find here? -->
      <!-- <span class="label">{i18n('Summary')}</span> -->
      {#if summaries.length > 1}
        <div class="header">
          <select bind:value={selectedSummary} aria-controls="summary-text">
            {#if splitOptions}
              <optgroup label={langLabel}>
                {#each highlightedSummaries as summary (summary.key)}
                  <option value={summary.key}>{summary.name}</option>
                {/each}
              </optgroup>
              <optgroup label={i18n('Other languages')}>
                {#each otherSummaries as summary (summary.key)}
                  <option value={summary.key}>{summary.name}</option>
                {/each}
              </optgroup>
            {:else}
              {#each summaries as summary (summary.key)}
                <option value={summary.key}>{summary.name}</option>
              {/each}
            {/if}
          </select>
        </div>
      {/if}
      {#await waitingForText}
        <Spinner center={true} />
      {:then}
        {#if summaryData.text}
          <p id="summary-text" lang={summaryData.lang} dir={getTextDirection(summaryData.lang)}>
            {summaryData.text}
            <span class="source">
              <Link url={summaryData.link} text={`${i18n('Source:')} ${summaryData.name}`} classNames="link" />
            </span>
          </p>
        {/if}
      {/await}
    {/if}
  {/await}

  <Flash state={flash} />
</div>

<style lang="scss">
  @import "#general/scss/utils";
  .summary.has-summary{
    padding: 1em;
    margin-top: 1em;
    @include radius;
    background-color: $off-white;
    :global(.spinner-centered){
      padding: 2em;
    }
  }
  .header{
    @include display-flex(row, baseline, space-between);
    margin-bottom: 0.5em;
  }
  // .label{
  //   color: $label-grey;
  //   margin-inline-start: 0.5em;
  // }
  select{
    max-width: 15em;
  }
  #summary-text{
    max-height: 10em;
    overflow-y: auto;
  }
  .source{
    margin-inline-start: 1em;
    :global(a){
      color: $grey;
    }
  }
  /* Large screens */
  @media screen and (min-width: $small-screen){
    .summary.has-summary{
      margin-top: 0;
    }
  }
</style>
