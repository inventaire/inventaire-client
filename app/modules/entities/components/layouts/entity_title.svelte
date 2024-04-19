<script lang="ts">
  import Link from '#app/lib/components/link.svelte'
  import { formatYearClaim } from '#entities/components/lib/claims_helpers'
  import type { SerializedEntity } from '#entities/lib/entities'
  import SourceLogo from '#inventory/components/entity_source_logo.svelte'
  import type { Url } from '#server/types/common'
  import { i18n } from '#user/lib/i18n'

  export let entity: SerializedEntity
  export let sourceLogo = false
  export let href: Url = null
  export let hasLinkTitle = false

  const { uri, claims, label } = entity
  const birthOrDeathDates = claims['wdt:P569'] || claims['wdt:P570']

  $: subtitle = claims['wdt:P1680']
</script>
<h2>
  {#if hasLinkTitle}
    <Link
      url={href || `entity/${uri}`}
      text={label}
      dark={true}
    />
  {:else}
    {label}
  {/if}
  {#if sourceLogo}
    <SourceLogo {entity} />
  {/if}
</h2>
{#if birthOrDeathDates}
  <div class="birth-or-death-dates">
    <span title={i18n('wdt:P569')}>
      {formatYearClaim('wdt:P569', claims)}
    </span>
    -
    <span title={i18n('wdt:P570')}>
      {formatYearClaim('wdt:P570', claims)}
    </span>
  </div>
{/if}
{#if subtitle}
  <div class="subtitle">
    {subtitle}
  </div>
{/if}
<style>
  h2{
    margin: 0;
  }
  .birth-or-death-dates{
    margin-block-end: 0.3em;
  }
  .subtitle{
    margin-block-end: 0.3em;
    color: #444;
  }
</style>
