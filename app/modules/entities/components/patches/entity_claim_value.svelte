<script lang="ts">
  import { getTextDirection } from '#app/lib/languages'
  import { loadInternalLink } from '#app/lib/utils'
  import { getEntityLabel } from '#entities/lib/entities'
  import type { EntityUri } from '#server/types/entity'

  export let uri: EntityUri

  let label, lang
  getEntityLabel(uri).then(res => ({ label, lang } = res))
</script>

{#if label && lang}
  <a
    href="/entity/{uri}"
    class="link"
    dir={getTextDirection(lang)}
    on:click={loadInternalLink}
  >
    {label}
  </a>
{/if}
