<script>
  export let large = false
  export let light = false
  export let center = false
</script>

<!-- The "spinner" class is set on the outer elements to let it be style from parent components -->
{#if large}
  <div class="spinner spinner-outer"><div class="spinner-inner" /></div>
{:else if center}
  <div class="spinner spinner-centered">
    <span class="small-spinner" class:light />
  </div>
{:else}
  <span class="spinner small-spinner" class:light />
{/if}

<style>
  .spinner-outer{
    position: fixed;
    inset: 0;
    display: flex;
    flex-direction: row;
    align-items: center;
    justify-content: center;
  }

  .spinner-inner{
    transform: translateY(-50%);
    display: inline-block;
    align-self: center;
  }

  .spinner-centered{
    text-align: center;
  }

  .small-spinner::after, .spinner-inner::after{
    content: " ";
    display: inline-flex;
    width: 1rem;
    height: 1rem;
    margin: 0 0.2rem;
    border-radius: 50%;
    animation: ring-loader 1.2s linear infinite;
    border: 2px solid;
  }

  .spinner-inner::after{
    font-size: 5rem;
    border-width: 8px;
    border-color: #222 #319cc2 #ffd402 transparent;
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
