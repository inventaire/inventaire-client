<script lang="ts">
  import { createEventDispatcher } from 'svelte'
  import { icon } from '#app/lib/icons'
  import type { SerializedEntity } from '#entities/lib/entities'

  export let author: SerializedEntity
  export let isSuggestion = false
  const { uri, label } = author

  const dispatch = createEventDispatcher()
</script>

<li class="serie-cleanup-author" class:suggestion={isSuggestion}>
  {#if isSuggestion}
    <button on:click={() => dispatch('add', uri)}>
      {@html icon('plus')}
      <span class="label">{label}</span>
      <span class="uri">{uri}</span>
    </button>
  {:else}
    <div>
      <span class="label">{label}</span>
      <span class="uri">{uri}</span>
    </div>
  {/if}
</li>

<style lang="scss">
  @import '#general/scss/utils';

  .serie-cleanup-author{
    margin: 0.2em 0;
    > button, > div{
      width: 100%;
      @include display-flex(row, center, flex-start);
      padding: 0.5em;
      @include radius;
      span{
        margin: 0 0.2rem;
      }
    }
    &:not(.suggestion) > div{
      background-color: white;
    }
    &.suggestion > button{
      @include bg-hover(#bbb);
      cursor: pointer;
    }
  }
</style>
