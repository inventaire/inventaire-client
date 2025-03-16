<script lang="ts">
  import app from '#app/app'
  import Flash from '#app/lib/components/flash.svelte'
  import { icon } from '#app/lib/icons'
  import log_ from '#app/lib/loggers'
  import Spinner from '#components/spinner.svelte'
  import EntityLabel from '#entities/components/entity_label.svelte'
  import LanguageLabel from '#entities/components/language_label.svelte'
  import { addClaim, getWikidataUrl, updateLabel } from '#entities/lib/entities'
  import type { InvEntityImportableData } from '#entities/lib/get_entity_wikidata_import_data'
  import { i18n, I18n } from '#user/lib/i18n'
  import { formatClaimValue } from './lib/claims_helpers'

  export let resolve: () => void
  export let importData: InvEntityImportableData

  const { labels, claims, wdEntity } = importData

  const wdUrl = getWikidataUrl(wdEntity.uri)

  app.execute('modal:open', 'medium')

  let flash
  let importing = false
  let imported = 0

  async function importSelectedData () {
    try {
      importing = true
      for (const labelData of labels) {
        if (labelData.checked) {
          log_.info(labelData, 'importing label')
          await updateLabel(wdEntity.uri, labelData.lang, labelData.label)
          imported++
        }
      }
      for (const claimData of claims) {
        if (claimData.checked) {
          log_.info(claimData, 'importing claim')
          // @ts-expect-error
          await addClaim(wdEntity, claimData.property, claimData.value)
          imported++
        }
      }
      done()
    } catch (err) {
      flash = err
    } finally {
      importing = false
    }
  }

  function done () {
    app.execute('modal:close')
    resolve()
  }

  function getCheckedCount (array: InvEntityImportableData['labels'] | InvEntityImportableData['claims']) {
    return array.filter(el => el.checked).length
  }

  $: totalChecked = getCheckedCount(labels) + getCheckedCount(claims)
</script>

<div class="wikidata-data-importer">
  <a
    class="show-on-wikidata"
    href={wdUrl}
    target="_blank"
    rel="noopener">
    {@html icon('wikidata-colored')}
    <div class="wd-entity-data">
      <p class="wd-entity-label">{wdEntity.label}</p>
      <p class="wd-entity-uri">{wdEntity.uri}</p>
    </div>
  </a>

  <h3>{I18n('The following data is missing on the Wikidata entity, which of those should be imported to Wikidata?')}</h3>

  <table>
    <tbody>
      {#each labels as labelData}
        <tr>
          <td>
            <label>
              <input type="checkbox" bind:checked={labelData.checked} data-type="label" />
              {i18n('label')}
            </label>
          </td>
          <td class="lang"><LanguageLabel lang={labelData.lang} /></td>
          <td class="label">{labelData.label}</td>
        </tr>
      {/each}
      {#each claims as claimData}
        <tr>
          <td>
            <label>
              <input type="checkbox" bind:checked={claimData.checked} />
              {i18n('claim')}
            </label>
          </td>
          <td class="property">{I18n(claimData.property)}<span class="property-uri">({claimData.property})</span></td>
          <td class="value">
            {#if claimData.datatype === 'entity'}
              <EntityLabel uri={claimData.value} />
              <span class="wd-entity-uri">({claimData.value})</span>
            {:else}
              {formatClaimValue({ prop: claimData.property, value: claimData.value })}
            {/if}
          </td>
        </tr>
      {/each}
    </tbody>
  </table>

  <Flash state={flash} />

  <button on:click={done} class="button grey" disabled={importing}>
    {@html icon('times')}
    {I18n('merge without importing data')}
  </button>
  <button on:click={importSelectedData} class="import-data button light-blue" disabled={importing}>
    {#if importing}
      <Spinner />
      <span class="counter">({imported}/{totalChecked})</span>
    {:else}
      {@html icon('check')}
    {/if}
    {I18n('import')}
  </button>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .wikidata-data-importer{
    text-align: center;
  }
  h3{
    font-size: 1.1em;
    @include sans-serif;
  }
  label, .wd-entity-uri, .property-uri, .counter{
    font-size: 1rem;
    color: $grey;
    font-weight: normal;
  }
  label{
    input[type="checkbox"]{
      margin-inline-end: 1rem;
    }
  }
  .lang{
    text-transform: capitalize;
  }
  .label, .value, .value :global(.entity-label){
    font-weight: bold;
  }
  table, .import-data{
    margin: 1em;
  }
  td{
    padding: 0 1em;
    text-align: start;
  }
  .property-uri{
    margin-inline-start: 0.5em;
  }
  .show-on-wikidata{
    @include display-flex(row, center, center);
    @include bg-hover(white);
    > div, :global(.fa){
      margin: 1em;
    }
  }
</style>
