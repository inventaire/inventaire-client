<script lang="ts">
  import { config } from '#app/config'
  import { getTextDirection, langs, regionify } from '#app/lib/active_languages'
  import { setQuerystring } from '#app/lib/location'
  import { locationStore } from '#app/lib/location_store'
  import { metadataStore, prerenderStatusStore } from '#app/lib/metadata/update'
  import { onChange } from '#app/lib/svelte/svelte'
  import { objectEntries } from '#app/lib/utils'
  import { localLang } from '#modules/user/lib/i18n'
  import type { AbsoluteUrl } from '#server/types/common'

  const { origin } = location
  const { instanceName } = config

  function updateDocumentLang () {
    if (typeof $localLang === 'string') {
      document.documentElement.setAttribute('lang', $localLang)
      document.documentElement.setAttribute('dir', getTextDirection($localLang))
    }
  }

  $: onChange($localLang, updateDocumentLang)
  $: baseHref = `${origin}/${$locationStore.route}` as AbsoluteUrl

  let url, title, description, image, rss, twitterCard
  $: {
    if ($metadataStore) {
      ;({ url, title, description, image, rss, 'twitter:card': twitterCard } = $metadataStore)
    }
  }

  let statusCode, header
  $: ({ statusCode, header } = $prerenderStatusStore)
</script>

<svelte:head>
  {#if $metadataStore}
    <title>{title}</title>
    <link rel="canonical" href={url} />

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

    <link rel="alternate" type="application/rss+xml" href={rss} />

    <meta name="twitter:title" content={title} />
    <meta name="twitter:card" content={twitterCard} />
    <meta name="twitter:description" content={description} />
    <meta name="twitter:image" content={image} />

    <meta property="og:site_name" content={instanceName} />
    <meta property="og:type" content="website" />
    <meta property="og:url" content={url} />
    <meta property="og:title" content={title} />
    <meta name="description" property="og:description" content={description} />
    <!-- limiting to one og:image to be sure it's the one selected. cf https://stackoverflow.com/questions/13424780/facebook-multiple-ogimage-tags-which-is-default -->
    <meta property="og:image" content={image} />

    {#if statusCode}
      <meta name="prerender-status-code" content={statusCode} />
      {#if header}
        <meta name="prerender-header" content={header} />
      {/if}
    {/if}
  {/if}
</svelte:head>
