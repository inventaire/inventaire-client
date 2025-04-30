<script lang="ts">
  import Flash from '#app/lib/components/flash.svelte'
  import { getLanguageLabel } from '#app/lib/languages_labels'
  import { capitalize } from '#app/lib/utils'
  import Spinner from '#components/spinner.svelte'
  import type { WikimediaLanguageCode } from 'wikibase-sdk'

  export let lang: WikimediaLanguageCode

  let label, flash
  getLanguageLabel(lang)
    .then(res => label = capitalize(res))
    .catch(err => flash = err)
</script>

<div class="lang-info">
  {#if label}
    <span class="lang-label">{label}</span>
  {:else}
    <Spinner />
  {/if}
  <span class="lang-code">({lang})</span>
</div>

<Flash state={flash} />

<style lang="scss">
  @import '#general/scss/utils';
  .lang-info{
    width: 10rem;
    line-height: 1.2rem;
  }
  .lang-code{
    align-self: stretch;
    text-align: start;
    color: $grey;
    word-break: keep-all;
  }
</style>
