<script lang="ts">
  import { isEntityUri, isImageHash } from '#app/lib/boolean_tests'
  import typeOf from '#app/lib/type_of'
  import EntityClaimValue from './entity_claim_value.svelte'
  import ImagePreview from './image_preview.svelte'

  export let value

  const valueType = typeOf(value)
</script>

{#if valueType === 'string'}
  {#if isEntityUri(value)}
    <EntityClaimValue uri={value} />
  {:else if isImageHash(value)}
    <ImagePreview imageHash={value} />
  {:else}
    {value}
  {/if}
{:else if valueType === 'number'}
  {value}
{:else if valueType === 'array'}
  {#each value as subvalue}
    <svelte:self value={subvalue} />
  {/each}
{:else if valueType === 'object'}
  {JSON.stringify(value)}
{/if}
