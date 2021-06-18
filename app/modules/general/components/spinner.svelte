<script>
  export let large = false, light = false
</script>

{#if large}
  <div class="spinner-outer"><div class="spinner-inner"></div></div>
{:else}
  <span class="small-spinner" class:light></span>
{/if}

<style>
  .spinner-outer{
    position: fixed;
    top: 0;
    right: 0;
    bottom: 0;
    left: 0;
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

  .small-spinner:after, .spinner-inner:after{
    content: " ";
    display: inline-flex;
    width: 1em;
    height: 1em;
    margin: 0 0.5em;
    border-radius: 50%;
    animation: ring-loader 1.2s linear infinite;
    border: 2px solid;
  }

  .spinner-inner:after{
    font-size: 5em;
    border-width: 8px;
    border-color: #222 #319cc2 #ffd402 transparent;
  }

  .small-spinner:not(.light):after{
    border-color: #333 #333 #333 transparent;
  }

  .small-spinner.light:after{
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
