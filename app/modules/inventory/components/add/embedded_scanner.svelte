<script lang="ts">
  import { onDestroy, onMount } from 'svelte'
  import { slide } from 'svelte/transition'
  import app from '#app/app'
  import Flash, { type FlashType } from '#app/lib/components/flash.svelte'
  import { icon } from '#app/lib/icons'
  import log_ from '#app/lib/loggers'
  import { wait } from '#app/lib/promises'
  import { arrayIncludes } from '#app/lib/utils'
  import { getEntityByUri } from '#app/modules/entities/lib/entities'
  import Spinner from '#components/spinner.svelte'
  import { startEmbeddedScanner } from '#inventory/lib/scanner/embedded'
  import { i18n, I18n } from '#user/lib/i18n'

  function displayAboveTopBar () {
    document.getElementById('main').style['z-index'] = '2'
  }

  function resetDisplay () {
    document.getElementById('main').style['z-index'] = '0'
  }

  let batch = []
  let notFound = []
  let loading = true
  let invalidIsbnDetected = false

  function beforeScannerStart () {
    loading = false
    showStatusMessage({
      type: 'info',
      message: I18n("make the book's barcode fit in the box"),
      displayTime: 29_000,
    })
    showStatusMessage({
      type: 'support',
      message: I18n('failing_scan_tip'),
      displayCondition: () => batch.length === 0 && !invalidIsbnDetected,
      displayDelay: 30_000,
      displayTime: 30_000,
    })
  }

  let lastIsbn, lastSuccessTime
  let highlightValidateScan = false
  function addIsbn (isbn: string) {
    lastIsbn = isbn
    if (arrayIncludes(batch, isbn)) return showDuplicateIsbnWarning(isbn)

    batch = [ ...batch, isbn ]
    precachingEntityData(isbn)

    lastSuccessTime = Date.now()
    showStatusMessage({
      message: i18n('added:') + ' ' + isbn,
      type: 'success',
      displayTime: 4000,
    })

    highlightValidateScan = true
    setTimeout(() => highlightValidateScan = false, 1000)

    if (batch.length === 1) {
      showStatusMessage({
        message: I18n('multi_barcode_scan_tip'),
        type: 'info',
        // Show the tip once the success message is over
        displayDelay: 2000,
        // Do not display if already several ISBNs were scanned
        displayCondition: () => batch.length === 1,
        displayTime: 5000,
      })
    }
  }

  let lastDuplicate
  function showDuplicateIsbnWarning (isbn: string) {
    const now = Date.now()
    if (lastSuccessTime == null) lastSuccessTime = 0
    if (lastDuplicate == null) lastDuplicate = 0

    const differentIsbn = isbn !== lastIsbn
    // Do not show to soon after the successful scan
    // and debounce duplicate messages
    const debounced = ((now - lastSuccessTime) > 5000) && ((now - lastDuplicate) > 3000)

    if (differentIsbn || debounced) {
      lastDuplicate = Date.now()
      showStatusMessage({
        message: I18n('this ISBN was already scanned'),
        type: 'warning',
        displayTime: 2000,
      })
    }
  }

  async function precachingEntityData (isbn: string) {
    // Pre-requesting the entity's data with autocreate=true to let the time to the server
    // to possibly fetch dataseeds, while we will only need the data later.
    // If successful, the entities will be pre-cached
    try {
      const entity = await getEntityByUri({ uri: `isbn:${isbn}` })
      if (!entity) notFound = [ ...notFound, isbn ]
    } catch (err) {
      log_.error(err, 'isbn batch pre-cache err')
    }
  }

  function showInvalidIsbnWarning (invalidIsbn: string) {
    invalidIsbnDetected = true
    showStatusMessage({
      message: i18n('invalid ISBN') + ': ' + invalidIsbn,
      type: 'warning',
      displayTime: 5000,
    })
  }

  let stopScanner: () => void
  function setStopScannerCallback (fn: () => void) {
    stopScanner = fn
  }

  let isDestroyed = false
  let statusFlash
  interface StatusMessageParams {
    message: string
    type: FlashType
    displayDelay?: number
    displayTime: number
    displayCondition?: () => boolean
  }
  async function showStatusMessage (params: StatusMessageParams) {
    const { message, type, displayDelay, displayCondition, displayTime } = params
    if (displayDelay) await wait(displayDelay)
    if (isDestroyed) return
    if ((displayCondition != null) && !displayCondition()) return
    statusFlash = { type, message, canBeClosed: false }
    await wait(displayTime)
    if (isDestroyed) return
    if (statusFlash && statusFlash.message === message) statusFlash = null
  }

  let errorFlash
  function permissionDenied (err: Error & { reason: string }) {
    if (err.reason === 'permission_denied') {
      log_.info('permission denied: closing scanner')
    } else {
      log_.error(err, 'scan error')
    }
    errorFlash = err
    // In any case, close
    setTimeout(closeScanner, 3000)
  }

  function validateScan () {
    app.execute('show:add:layout:import:isbns', batch)
  }

  function closeScanner () {
    // come back to the previous view
    // which should trigger this component destroy as the previous component is expected to be shown
    // in app.layout.getRegion('main') too
    window.history.back()
  }

  let containerEl: HTMLElement

  onMount(() => {
    startEmbeddedScanner({
      containerElement: containerEl,
      beforeScannerStart,
      onDetectedActions: {
        addIsbn,
        showInvalidIsbnWarning,
      },
      setStopScannerCallback,
    }).catch(permissionDenied)
    displayAboveTopBar()
  })

  onDestroy(() => {
    isDestroyed = true
    resetDisplay()
    stopScanner?.()
  })
</script>

<div class="embedded-scanner">
  <div class="container" bind:this={containerEl}>
    {#if loading}
      <div class="loading">
        <Spinner light={true} />
      </div>
    {/if}
  </div>
  <Flash state={errorFlash} />
  {#if statusFlash}
    <div class="status-message" transition:slide>
      <Flash state={statusFlash} />
    </div>
  {/if}
  {#if !loading && batch.length === 0}
    <div class="shadow-video-box">
      <!-- After the first successful scan, the shadow barcode shouldn't be needed anymore -->
      <div class="shadow-area-box">
        {@html icon('barcode')}
      </div>
    </div>
  {/if}
  <div class="bottom">
    {#if batch.length > 0}
      <button
        class="validate-scan success-button"
        class:highlight={highlightValidateScan}
        on:click={validateScan}
      >
        {I18n('validate')}
        <span class="total-counter">({batch.length})</span>
      </button>
    {/if}
    {#if notFound.length > 0}
      <div class="not-found">
        {@html icon('warning')}
        {i18n('Editions needing additional information:')}
        <span class="not-found-counter">{notFound.length}</span>
      </div>
    {/if}
  </div>
  <button class="close-scan" on:click={closeScanner}>{@html icon('times')}</button>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .embedded-scanner{
    @include position(fixed, 0, 0, 0, 0, 1);
    background-color: rgba(#222, 0.9);
    text-align: center;
  }
  .container :global(video), .container :global(canvas.drawingBuffer), .loading{
    @include position(absolute, 50%, null, null, 50%);
    // centering
    transform: translate(-50%, -50%);
    // avoid scrolls
    overflow: hidden;
  }
  $close-button-width: 3rem;
  $status-message-horizontal-margin: calc($close-button-width + 0.1em);
  .status-message{
    @include position(fixed, 1em, $status-message-horizontal-margin, null, $status-message-horizontal-margin);
    :global(.flash){
      padding: 0.4em 0.2em !important;
    }
    :global(.success){
      background-color: rgba($success-color, 0.8) !important;
      color: white !important;
    }
    :global(.info), :global(.support), :global(.warning){
      background-color: rgba($dark-grey, 0.8) !important;
      color: white !important;
    }
  }
  .bottom{
    @include position(fixed, null, 0, 0, 0);
  }
  .not-found{
    background-color: rgba($dark-grey, 0.8);
    color: white;
    :global(.fa-warning){
      margin-inline-end: 0.5em;
    }
    padding: 0.5em;
  }
  .not-found-counter{
    margin-inline-start: 0.5em;
  }
  .shadow-video-box{
    @include position(fixed, 50%, null, null, 50%);
    height: 480px;
    width: 640px;
    margin-block-start: -240px;
    margin-inline-start: -320px;
    opacity: 0.5;
  }
  .shadow-area-box{
    position: absolute;
    inset-block-start: 30%;
    inset-inline-end: 15%;
    inset-inline-start: 15%;
    inset-block-end: 30%;
    @include display-flex(row, center, center);
    :global(.fa-barcode){
      font-size: 160px;
      color: rgba(grey, 0.5);
      margin-inline-start: -3rem;
      transform: scale(1.5, 1);
    }
  }
  .validate-scan{
    &:not(.hidden){
      display: block;
    }
    margin: 1em auto;
    max-width: 10em;
    &.highlight{
      @include flash($success-color);
    }
  }
  .close-scan{
    @include position(fixed, 0, 0);
    @include text-hover(white);
    @include display-flex(row, center, center);
    font-size: 2em;
    width: $close-button-width;
    height: $close-button-width;
    border-end-start-radius: $global-radius;
  }
</style>
