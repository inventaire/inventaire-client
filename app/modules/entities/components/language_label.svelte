<script lang="ts">
  import { getWdUriFromWikimediaLanguageCode } from '#app/lib/languages'
  import EntityLabel from '#entities/components/entity_label.svelte'

  export let lang: string

  const uri = getWdUriFromWikimediaLanguageCode(lang)
</script>

{#if uri}
  <EntityLabel {uri} />
{:else}
  <span class="lang-code">{lang}</span>
{/if}
