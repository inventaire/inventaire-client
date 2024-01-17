<script>
  import { externalIdsDisplayConfigs } from '#entities/lib/entity_links'
  import Link from '#lib/components/link.svelte'

  export let name, property, value

  let url
  if (externalIdsDisplayConfigs[property]) {
    const { getUrl } = externalIdsDisplayConfigs[property]
    if (getUrl) url = getUrl(value)
  }
</script>

{#if url}
  <!-- TODO: set an icon instead of a text -->
  <Link
    {url}
    text={name}
    title={name}
    classNames="link"
  />
{:else}
  {value}
{/if}
