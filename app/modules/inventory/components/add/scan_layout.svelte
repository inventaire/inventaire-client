<script lang="ts">
  import { getDevicesInfo } from '#app/lib/has_video_input'
  import { icon } from '#app/lib/icons'
  import { commands } from '#app/radio'
  import { i18n, I18n } from '#user/lib/i18n'

  const { hasVideoInput, doesntSupportEnumerateDevices, tip } = getDevicesInfo()

  function startEmbeddedScanner () {
    commands.execute('show:scanner:embedded')
  }
</script>

<div class="scan-layout">
  {#if hasVideoInput}
    <section class="inner">
      <button class="button radius bold secondary" on:click={startEmbeddedScanner}>
        {@html icon('barcode')}
        {I18n('scan a barcode')}
      </button>
    </section>
  {:else}
    <section class="inner">
      <h3>{I18n('add_by_barcode_scan')}</h3>
      <p class="disabled">
        {@html icon('ban')}
        {#if doesntSupportEnumerateDevices}
          <span>{@html i18n('scanner_disabled_tip_2')}</span>
        {:else}
          <span>{i18n('requires an activated camera')}</span>
        {/if}
      </p>
      {#if tip}
        <pre>{@html icon('warning')} {tip}</pre>
      {/if}
    </section>
  {/if}

  <!-- TODO: add a note on the possibility to use barcode reader devices -->
</div>

<style lang="scss">
  @use '#general/scss/utils';

  $scan-contrast: #f5f5f5;

  .scan-layout{
    max-width: 30em;
    margin: auto;
    text-align: center;
  }
  section{
    padding: 1em;
  }
  .button{
    margin: 1em auto;
    :global(.fa){
      margin-inline-end: 0.5em;
    }
    /* Small screens */
    @media screen and (width < $small-screen){
      // make it stand-out more
      margin-block-start: 2em;
      margin-block-end: 2em;
    }
  }
  .disabled{
    padding: 1em;
    background-color: grey;
    color: white;
    @include radius;
    font-size: 1em;
    :global(.fa){
      font-size: 2em;
      display: block;
      margin: 0 auto;
    }
    // the "modern browsers" link in the i18n block
    :global(span a){
      @include text-hover(white, #eee);
      @include underline(white);
    }
  }
  pre{
    margin: 1rem 0;
    padding: 0.5rem;
    max-width: 100%;
    overflow-x: auto;
    background-color: $grey;
    text-align: start;
  }

  // @use 'embedded';
</style>
