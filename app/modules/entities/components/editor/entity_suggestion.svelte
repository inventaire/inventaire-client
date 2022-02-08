<script>
  import { createEventDispatcher } from 'svelte'
  export let suggestion, highlight
  let element
  const { uri, label, description } = suggestion
  const dispatch = createEventDispatcher()
  const select = () => dispatch('select')

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
    on:click={select}
    class:highlight={highlight}
    >
    <div class="top">
      <span class="label">{label}</span>
      <a class="uri" href="/entity/{uri}" target="_blank" on:click|stopPropagation>{uri}</a>
    </div>
    {#if description}<span class="description">{description}</span>{/if}
  </button>
</li>

<style lang="scss">
  @import 'app/modules/general/scss/utils';
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
  .label{
    font-weight: bold;
    text-align: left;
  }
  .description, .uri{
    font-weight: normal;
  }
  .description{
    color: $grey;
    display: block;
    text-align: left;
    font-weight: normal;
  }
  .uri{
    white-space: nowrap;
    align-self: flex-start;
  }
</style>
