<script lang="ts">
  import { tick } from 'svelte'
  import app from '#app/app'
  import Link from '#app/lib/components/link.svelte'
  import { icon as iconFn } from '#app/lib/handlebars_helpers/icons'
  import { treq } from '#app/lib/preq'
  import type { Entity } from '#app/types/entity'
  import { getWikidataUrl, getWikidataHistoryUrl, serializeEntity } from '#entities/lib/entities'
  import Spinner from '#general/components/spinner.svelte'
  import type { GetEntitiesByUrisResponse } from '#server/controllers/entities/by_uris_get'
  import { i18n, I18n } from '#user/lib/i18n'

  export let entity, showEntityEditButtons = true

  let waitForEntityRefresh

  const { uri, type, claims } = entity

  const refreshEntity = async () => {
    waitForEntityRefresh = treq.get<GetEntitiesByUrisResponse>(app.API.entities.getByUris(uri, true))
    const { entities } = await waitForEntityRefresh
    entity = serializeEntity(Object.values(entities)[0] as Entity)
    // Let other components know that a refresh was requested
    entity.refreshTimestamp = Date.now()
    // Let time for other components to trigger a server cache refresh if needed
    // and pass the resulting promise to pushEntityRefreshingPromise
    await tick()
    waitForEntityRefresh = entity.refreshing
    await waitForEntityRefresh
    // Set refresh parameter to force router to navigate, despite the pathname being the same
    app.navigateAndLoad(`${entity.pathname}?refresh=true`)
  }

  const wikidataUrl = getWikidataUrl(uri)
  const wikidataHistoryUrl = getWikidataHistoryUrl(uri)
</script>

{#if showEntityEditButtons}
  <li>
    <Link
      url={`/entity/${uri}/edit`}
      text={i18n('Edit bibliographical info')}
      icon="pencil"
    />
  </li>
{/if}

{#if wikidataUrl}
  <li>
    <Link
      url={wikidataUrl}
      text={I18n('see_on_website', { website: 'wikidata.org' })}
      icon="wikidata"
    />
  </li>
  <li>
    <button
      on:click={refreshEntity}
      title={I18n('refresh Wikidata data')}
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
      icon="history"
    />
  </li>
{:else}
  {#if claims['wdt:P212']}
    <li>
      <button
        on:click={refreshEntity}
        title={I18n('refresh external databases data')}
      >
        {#await waitForEntityRefresh}
          <Spinner />
        {:then}
          {@html iconFn('refresh')}
        {/await}
        <span class="button-text">{I18n('refresh external databases data')}</span>
      </button>
    </li>
  {/if}
  <li>
    <Link
      url={`/entity/${uri}/history`}
      text={I18n('entity history')}
      icon="history"
    />
  </li>
{/if}

{#if app.user.hasDataadminAccess && showEntityEditButtons}
  {#if type === 'human'}
    <li>
      <Link
        url={`/entity/${uri}/deduplicate`}
        text={i18n('Deduplicate sub-entities')}
        icon="compress"
      />
    </li>
  {/if}
  {#if type === 'serie'}
    <li>
      <Link
        url={`/entity/${uri}/cleanup`}
        text={I18n('cleanup entity')}
        icon="arrows"
      />
    </li>
  {/if}
{/if}
