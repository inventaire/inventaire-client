<script lang="ts">
  import { isEntityUri, isImageHash } from '#app/lib/boolean_tests'
  import typeOf from '#app/lib/type_of'
  import { i18n } from '#user/lib/i18n'
  import EntityClaimValue from './entity_claim_value.svelte'
  import ImagePreview from './image_preview.svelte'
  import OperationValueReference from './operation_value_reference.svelte'

  export let value

  let references
  if (value.value) {
    ;({ value, references } = value)
  }

  const valueType = typeOf(value)
</script>

<div class="operation-value-wrapper" class:nested={valueType === 'array'}>
  <div class="operation-value">
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
  </div>

  {#if references}
    <div class="references">
      {i18n('References')}:
      {#each references as reference}
        {#each Object.entries(reference) as [ property, values ]}
          <OperationValueReference {property} {values} />
        {/each}
      {/each}
    </div>
  {/if}
</div>

<style lang="scss">
  @use '#general/scss/utils';
  .operation-value-wrapper:not(.nested){
    @include display-flex(row, center, space-between);
    margin-inline-end: auto;
  }
  .references{
    font-size: 0.9rem;
    color: $grey;
    background-color: #eee;
    padding: 0.2rem 0.4rem;
    margin-inline-start: auto;
    @include radius;
  }
</style>
