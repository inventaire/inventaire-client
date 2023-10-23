<script>
  import { i18n, I18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import { getFirstFileDataUrl, resetFileInput } from '#lib/files'
  import { getCropper, getImageHashFromDataUrl, getUrlDataUrl } from '#lib/images'
  import { isUrl } from '#lib/boolean_tests'
  import Spinner from '#components/spinner.svelte'
  import { createEventDispatcher } from 'svelte'

  export let currentValue, getInputValue, fileInput, waitingForCropper, imageElement

  let urlValue, files, dataUrl, dataUrlBeforeImageEdits, waitingForDataUrl
  const dispatch = createEventDispatcher()

  getInputValue = async () => {
    await waitingForDataUrl
    if (imageWasCropped || imageWasRotated) {
      dataUrl = getEditedImageDataUrl()
    }
    if (dataUrl) {
      return getImageHashFromDataUrl('entities', dataUrl)
    } else {
      return currentValue
    }
  }

  async function onUrlChange () {
    try {
      resetFileInput(fileInput)
      if (isUrl(urlValue)) {
        waitingForDataUrl = getUrlDataUrl(urlValue)
        dataUrl = await waitingForDataUrl
        dataUrlBeforeImageEdits = dataUrl
      }
    } catch (err) {
      dispatch('error', err)
    }
  }
  const lazyOnUrlChange = _.debounce(onUrlChange, 500)

  async function onFilesChange () {
    urlValue = null
    waitingForDataUrl = getFirstFileDataUrl({ fileList: files })
    dataUrl = await waitingForDataUrl
    dataUrlBeforeImageEdits = dataUrl
  }

  $: urlValue && lazyOnUrlChange()
  $: files && onFilesChange()

  let Cropper, cropper, cropperPromise
  async function importCropperLib () {
    if (!Cropper) {
      cropperPromise = cropperPromise || getCropper()
      Cropper = await cropperPromise
    }
  }

  let imageWasCropped = false
  async function initCropper () {
    if (imageElement) {
      if (cropper && imageElement.className.includes('cropper')) {
        cropper.replace(dataUrl)
      } else {
        await importCropperLib()
        cropper = new Cropper(imageElement, {
          viewMode: 2,
          autoCropArea: 1,
          minContainerHeight: 0,
          minContainerWidth: 0,
          minCropBoxWidth: 100,
          minCropBoxHeight: 100,
          zoomable: false,
          crop: () => imageWasCropped = true
        })
      }
    }
  }

  // Should be called as soon as either dataUrl or currentValue becomes defined
  $: if (dataUrl || currentValue) importCropperLib()
  // initCropper should be called everytime dataUrl changed or imageElement was initialized
  $: if (dataUrl || imageElement) initCropper()

  function onWindowResize () {
    if (cropper) setTimeout(cropper.reset.bind(cropper), 50)
  }

  let imageWasRotated = false
  function rotate (degrees) {
    cropper.rotate(degrees)
    const { naturalWidth, naturalHeight, rotate } = cropper.getImageData()
    imageWasRotated = rotate % 360 !== 0
    const { width, height } = cropper.getContainerData()
    let horizontalRatio, verticalRatio
    if (rotate % 180 === 0) {
      horizontalRatio = width / naturalWidth
      verticalRatio = height / naturalHeight
    } else {
      horizontalRatio = width / naturalHeight
      verticalRatio = height / naturalWidth
    }
    let ratio
    if (horizontalRatio < verticalRatio && horizontalRatio < 1) {
      ratio = horizontalRatio
    } else if (horizontalRatio > verticalRatio && verticalRatio < 1) {
      ratio = verticalRatio
    }
    if (ratio) {
      cropper.options.zoomable = true
      cropper.zoomTo(ratio)
      cropper.options.zoomable = false
    }

    // Maximize the cropbox
    cropper.setCropBoxData(cropper.getContainerData())
  }

  function reset () {
    cropper.replace(dataUrlBeforeImageEdits)
    cropper.reset()
  }

  function getEditedImageDataUrl () {
    const canvas = cropper.getCroppedCanvas()
    return canvas.toDataURL('image/jpeg', 1)
  }
</script>

<svelte:window on:resize={onWindowResize} />

<div class="wrapper">
  <label>
    {@html icon('link')}{I18n('from a URL')}
    <input
      type="url"
      placeholder={I18n('enter an image url')}
      bind:value={urlValue}
    />
  </label>

  <label>
    {@html icon('upload')}{I18n('from a file')}
    <input
      type="file"
      accept="image/*"
      bind:files
      bind:this={fileInput}
    />
  </label>

  {#await Promise.all([ waitingForCropper, waitingForDataUrl ])}
    <Spinner />
  {:then}
    {#if dataUrl || currentValue}
      <div class="image-wrapper">
        <img
          src={dataUrl || `/img/entities/${currentValue}`}
          alt={i18n('Image preview')}
          loading="lazy"
          bind:this={imageElement}
        />
      </div>
      <div class="controls">
        <button
          class="tiny-button grey"
          on:click={() => rotate(-90)}
          title={i18n('Rotate left')}
        >
          {@html icon('rotate-left')}
        </button>
        <button
          class="tiny-button grey"
          on:click={() => rotate(90)}
          title={i18n('Rotate right')}
        >
          {@html icon('rotate-right')}
        </button>
        <button
          class="tiny-button grey"
          on:click={reset}
          title={i18n("Reset image to it's initial state")}
        >
          {@html icon('refresh')}
          {i18n('Reset')}
        </button>
      </div>
    {/if}
  {/await}
</div>

<style lang="scss">
  @import "#general/scss/utils";
  .wrapper{
    min-block-size: 18em;
    margin-block-end: 0.5em;
    flex: 1;
  }
  label{
    display: block;
    max-inline-size: 25em;
    margin-block-end: 1em;
  }
  img{
    max-block-size: 30em;
  }
  input{
    margin: 0 0.2em 0 0;
  }
  input:invalid{
    border: 2px red solid;
  }
  .controls{
    @include display-flex(row, center, center);
    button{
      margin: 0.5em 0.2em;
      padding: 0.5em;
    }
  }
</style>
