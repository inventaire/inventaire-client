<script>
  import app from '#app/app'
  import { I18n } from '#user/lib/i18n'
  import { createItem } from '#inventory/components/create_item'
  import Spinner from '#general/components/spinner.svelte'
  import { createEntitiesByCandidate } from '#inventory/components/importer/create_candidate_entities'

  export let candidate
  export let listing
  export let transaction
  let retrying, editionPathname

  const { edition, details, error, item } = candidate
  const retryCreateItem = async () => {
    if (!edition) {
      const candidateWithEntities = await createEntitiesByCandidate(candidate)
      candidate = candidateWithEntities
    }

    await createItem(edition, details, transaction, listing)
    .then(newItem => {
      if (newItem) {
        candidate.error = undefined
        candidate.item = newItem
      }
    })
    .catch(err => candidate.error = err.responseJSON)
    .finally(() => retrying = false)
  }

  $: {
    const username = app.user.get('username')
    if (edition) editionPathname = `/inventory/${username}/${edition.uri}`
  }

  const lazyRetry = _.debounce(retryCreateItem, 200)
</script>
{#if error}
  <button on:click="{lazyRetry}" on:click="{() => retrying = true}">
    {I18n('Retry')}
    {#if retrying}
      <Spinner/>
    {/if}
  </button>
{/if}
{#if item}
  <a class="view-book tiny-button light-blue" href="{editionPathname}" target='_blanck' on:click="{() => app.execute('show:item:byId', item._id)}">
      {I18n('View book')}
    </a>
{/if}

<style>
  .view-book{
    min-width: 6em;
    text-align: center;
  }
</style>
