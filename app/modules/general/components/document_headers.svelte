<script lang="ts">
  import { getTextDirection, langs, regionify } from '#app/lib/active_languages'
  import { setQuerystring } from '#app/lib/location'
  import { locationStore } from '#app/lib/location_store'
  import { onChange } from '#app/lib/svelte/svelte'
  import { objectEntries } from '#app/lib/utils'
  import { localLang } from '#modules/user/lib/i18n'
  import type { AbsoluteUrl } from '#server/types/common'

  const { origin } = location

  function updateDocumentLang () {
    if (typeof $localLang === 'string') {
      document.documentElement.setAttribute('lang', $localLang)
      document.documentElement.setAttribute('dir', getTextDirection($localLang))
    }
  }

  $: onChange($localLang, updateDocumentLang)
  $: baseHref = `${origin}/${$locationStore.route}` as AbsoluteUrl
</script>

<svelte:head>
  <!-- The default lang - en - doesnt need a lang querystring to be set.
  It could have one, but search engines need to know that the default url
  they got matches this languages hreflang -->
  <link rel="alternate" href={baseHref} hreflang="en" />
  {#each langs as lang}
    {#if lang !== 'en'}
      <link rel="alternate" href={setQuerystring(baseHref, 'lang', lang)} hreflang={lang} />
    {/if}
  {/each}

  {#if typeof $localLang === 'string'}
    <meta property="og:locale" content={regionify[$localLang]} />
  {/if}

  {#each objectEntries(regionify) as [ lang, territory ]}
    {#if lang !== $localLang}
      <meta property="og:locale:alternate" content={territory} />
    {/if}
  {/each}
</svelte:head>
