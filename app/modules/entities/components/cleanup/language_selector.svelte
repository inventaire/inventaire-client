<script lang="ts">
  import { getLangsData } from '#entities/lib/editor/get_langs_data'
  import type { WikimediaLanguageCode } from 'wikibase-sdk'

  export let selectedLang: WikimediaLanguageCode

  const languages = getLangsData(selectedLang, {})
</script>

<select
  class="langSelector"
  aria-label="lang selector"
  name="language-selector"
  bind:value={selectedLang}
>
  {#each languages as { code, selected, native }}
    <option value={code} {selected}>{native}</option>
  {/each}
</select>
