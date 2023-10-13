<!-- See also FullScreenLoader component -->
<script>
  export let light = false
  export let center = false
</script>

<!-- The "spinner" class is set on the outer elements to let it be style from parent components -->
{#if center}
  <div class="spinner spinner-centered">
    <span class="small-spinner" class:light />
  </div>
{:else}
  <span class="spinner small-spinner" class:light />
{/if}

<style>
  .spinner-centered{
    text-align: center;
  }

  .small-spinner::after{
    content: " ";
    display: inline-flex;
    width: 1rem;
    height: 1rem;
    margin: 0 0.2rem;
    border-radius: 50%;
    animation: ring-loader 1.2s linear infinite;
    border: 2px solid;
  }

  .small-spinner:not(.light)::after{
    border-color: #333 #333 #333 transparent;
  }

  .small-spinner.light::after{
    border-color: white white white transparent;
  }

  @keyframes ring-loader{
    0%{
      transform: rotate(0deg);
    }
    100%{
      transform: rotate(360deg);
    }
  }
</style>
