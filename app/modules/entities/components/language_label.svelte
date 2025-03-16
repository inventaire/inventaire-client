<script lang="ts">
  import EntityLabel from '#entities/components/entity_label.svelte'
  import { getLangUri } from '#entities/lib/editor/get_langs_data'

  export let lang: string

  const uri = getLangUri(lang)
</script>

{#if uri}
  <EntityLabel {uri} />
{:else}
  <span class="lang-code">{lang}</span>
{/if}
