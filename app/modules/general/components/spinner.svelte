<script>
  export let large = false
</script>

{#if large}
  <div class="spinner-outer"><div class="spinner-inner"></div></div>
{:else}
  <span class="small-spinner"></span>
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
    display: inline-block;
    width: 1em;
    height: 1em;
    margin: 0 0.5em;
    border-radius: 50%;
    animation: ring-loader 1.2s linear infinite;
    border: 2px solid;
  }

  .small-spinner:after{
    border-color: #333 #333 #333 transparent;
  }

  .spinner-inner:after{
    border-color: #222 #319cc2 #ffd402 transparent;
    font-size: 5em;
    border-width: 8px;
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
