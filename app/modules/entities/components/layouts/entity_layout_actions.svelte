<script>
  import { i18n, I18n } from '#user/lib/i18n'
  import preq from '#lib/preq'
  import { getWikidataUrl, getWikidataHistoryUrl, serializeEntity } from '#entities/lib/entities'
  import Link from '#lib/components/link.svelte'
  import { icon as iconFn } from '#lib/handlebars_helpers/icons'
  import Spinner from '#general/components/spinner.svelte'
  import app from '#app/app'

  export let entity

  let waitForEntityRefresh

  const { uri, type } = entity

  const refreshEntity = async () => {
    waitForEntityRefresh = preq.get(app.API.entities.getByUris(uri, true))
    const { entities } = await waitForEntityRefresh
    entity = serializeEntity(Object.values(entities)[0])
    // Let other components now that a refresh was requested
    entity.refreshTimestamp = Date.now()
  }

  const wikidataUrl = getWikidataUrl(uri)
  const wikidataHistoryUrl = getWikidataHistoryUrl(uri)
</script>

<li>
  <Link
    url={`/entity/${uri}/edit`}
    text={i18n('Edit bibliographical info')}
    icon='pencil'
  />
</li>

{#if wikidataUrl}
  <li>
    <Link
      url={wikidataUrl}
      text={I18n('see_on_website', { website: 'wikidata.org' })}
      icon='wikidata'
    />
  </li>
  <li>
    <button
      on:click={refreshEntity}
      title="{I18n('refresh Wikidata data')}"
    >
      {#await waitForEntityRefresh}
        <Spinner />
      {:then}
        {@html iconFn('refresh')}
      {/await}
      <span class="button-text">{I18n('refresh Wikidata data')}</span>
    </button>
  </li>
  <li>
    <Link
      url={wikidataHistoryUrl}
      text={I18n('entity history')}
      icon='history'
    />
  </li>
{:else}
  <li>
    <Link
      url={`/entity/${uri}/history`}
      text={I18n('entity history')}
      icon='history'
    />
  </li>
{/if}

{#if app.user.hasDataadminAccess}
  {#if type === 'human'}
    <li>
      <Link
        url={`/entity/${uri}/deduplicate`}
        text={I18n('deduplicate sub-entities')}
        icon='compress'
      />
    </li>
  {/if}
  {#if type === 'serie'}
    <li>
      <Link
        url={`/entity/${uri}/cleanup`}
        text={I18n('cleanup entity')}
        icon='arrows'
      />
    </li>
  {/if}
{/if}
