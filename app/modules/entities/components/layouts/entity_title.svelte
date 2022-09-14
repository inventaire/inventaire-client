<script>
  import { i18n } from '#user/lib/i18n'
  import Link from '#lib/components/link.svelte'
  import { formatYearClaim } from '#entities/components/lib/claims_helpers'

  export let entity
  export let standalone = true

  const { uri, claims, label } = entity
  const birthOrDeathDates = claims['wdt:P569'] || claims['wdt:P570']

  $: subtitle = claims['wdt:P1680']
</script>
<h2>
  {#if standalone}
    {label}
  {:else}
    <Link
      url={`/entity/${uri}`}
      text={label}
      dark={true}
    />
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
    margin-bottom: 0.3em;
  }
  .subtitle{
    margin-bottom: 0.3em;
    color: #444;
  }
</style>
