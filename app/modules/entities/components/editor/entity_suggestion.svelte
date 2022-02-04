<script>
  import { createEventDispatcher } from 'svelte'
  export let suggestion
  const { uri, label, description } = suggestion
  const dispatch = createEventDispatcher()
  const select = () => dispatch('select')
</script>

<li>
  <button on:click={select}>
    <div class="top">
      <span class="label">{label}</span>
      <span class="uri">{uri}</span>
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
