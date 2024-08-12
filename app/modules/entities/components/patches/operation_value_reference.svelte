<script lang="ts">
  import Link from '#app/lib/components/link.svelte'
  import { externalIdsDisplayConfigs } from '#entities/lib/entity_links'

  export let property
  export let values

  let name, getUrl
  if (externalIdsDisplayConfigs[property]) {
    ;({ name, getUrl } = externalIdsDisplayConfigs[property])
  }
</script>

{#if getUrl}
  {#each values as value}
    <Link
      url={getUrl(value)}
      text={name}
      title={name}
      classNames="link"
    />
  {/each}
{:else}
  <!-- {value} -->
{/if}
