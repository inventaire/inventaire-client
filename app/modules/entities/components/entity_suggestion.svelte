<script>
  import { createEventDispatcher } from 'svelte'
  import { entityTypeNameByType } from '#entities/lib/types/entities_types'
  import { I18n } from '#user/lib/i18n'
  export let suggestion, highlight, displaySuggestionType = false
  let element
  const { uri, type, label, description } = suggestion
  const dispatch = createEventDispatcher()
  const typeName = entityTypeNameByType[type]

  $: {
    if (element && highlight) {
      element.parentElement.scroll({
        top: Math.max(0, (element.offsetTop - 20)),
        behavior: 'smooth'
      })
    }
  }
</script>

<li bind:this={element}>
  <button
    on:click={() => dispatch('select')}
    class:highlight={highlight}
    >
    <div class="top">
      <span class="label">{label}</span>
      <a class="uri" href="/entity/{uri}" target="_blank" on:click|stopPropagation>{uri}</a>
    </div>
    <div class="bottom">
      {#if description}<span class="description">{description}</span>{/if}
      {#if displaySuggestionType}<span class="type">{I18n(typeName)}</span>{/if}
    </div>
  </button>
</li>

<style lang="scss">
  @import '#general/scss/utils';
  li{
    margin: 0;
  }
  button{
    @include bg-hover(white);
    padding: 0.5em;
    width: 100%;
    margin: 0;
  }
  .highlight{
    background-color: #ddd;
  }
  .top{
    @include display-flex(row, center, space-between);
  }
  .bottom{
    @include display-flex(row, center, space-between);
  }
  .label{
    font-weight: bold;
    text-align: left;
    margin-right: auto;
  }
  .description, .uri{
    font-weight: normal;
  }
  .type, .description{
    text-align: left;
  }
  .description{
    color: $grey;
    display: block;
  }
  .type{
    color: $grey;
    text-align: right;
    font-size: 0.9rem;
  }
  .uri{
    white-space: nowrap;
    align-self: flex-start;
  }
</style>
