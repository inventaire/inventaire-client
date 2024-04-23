<script lang="ts">
  import { createEventDispatcher } from 'svelte'
  import { debounce } from 'underscore'
  import { isUrl } from '#app/lib/boolean_tests'
  import Flash from '#app/lib/components/flash.svelte'
  import { getFirstFileDataUrl, resetFileInput } from '#app/lib/files'
  import { icon } from '#app/lib/icons'
  import { getCropper, getImageHashFromDataUrl, getUrlDataUrl, getUserGravatarUrl, resizeDataUrl } from '#app/lib/images'
  import { stopEscPropagation } from '#app/lib/key_events'
  import { onChange } from '#app/lib/svelte/svelte'
  import Spinner from '#components/spinner.svelte'
  import { I18n } from '#user/lib/i18n'

  export let picture
  export let aspectRatio = null
  export let imageContainer
  export let savePicture
  export let deletePicture
  export let userContext = false

  const maxSize = 1600

  let dataUrl, waitingForDataUrl, flash, urlValue, files, fileInput

  const dispatch = createEventDispatcher()

  if (isUrl(picture)) {
    waitingForDataUrl = getUrlDataUrl(picture)
      .then(async originalDataUrl => {
        ;({ dataUrl } = await resizeDataUrl(originalDataUrl, maxSize))
      })
      .catch(err => flash = err)
  }

  let Cropper, cropper, imageElement
  async function initCropper () {
    if (!(dataUrl && imageElement)) return
    if (cropper) {
      cropper.replace(dataUrl)
    } else {
      Cropper = Cropper || await getCropper()
      cropper = new Cropper(imageElement, {
        viewMode: 2,
        aspectRatio,
        autoCropArea: 1,
        minCropBoxWidth: 300,
        minCropBoxHeight: 300,
        zoomable: false,
      })
    }
  }

  $: onChange(dataUrl, imageElement, initCropper)

  async function fetchGravatar () {
    urlValue = await getUserGravatarUrl()
  }

  let deleting
  async function _deletePicture () {
    try {
      deleting = true
      await deletePicture()
      dispatch('close')
    } catch (err) {
      flash = err
    } finally {
      deleting = false
    }
  }

  async function validatePicture () {
    const canvas = cropper.getCroppedCanvas()
    const newDataUrl = canvas.toDataURL('image/jpeg', 1)
    await save(newDataUrl)
    if (!(flash instanceof Error)) dispatch('close')
  }

  let saving
  async function save (newDataUrl) {
    try {
      saving = true
      const imageHash = await getImageHashFromDataUrl(imageContainer, newDataUrl)
      await savePicture(imageHash)
    } catch (err) {
      flash = err
    } finally {
      saving = false
    }
  }

  async function onUrlChange () {
    flash = null
    try {
      resetFileInput(fileInput)
      if (isUrl(urlValue)) {
        dataUrl = await getUrlDataUrl(urlValue)
      }
    } catch (err) {
      flash = err
    }
  }
  const lazyOnUrlChange = debounce(onUrlChange, 500)
  $: if (urlValue) lazyOnUrlChange()

  async function onFilesChange () {
    flash = null
    urlValue = null
    dataUrl = await getFirstFileDataUrl({ fileList: files })
  }
  $: if (files) onFilesChange()
</script>

<div class="image-inputs">
  <h4>{I18n('import a picture')}</h4>
  <div class="box">
    <label>
      {@html icon('link')}
      {I18n('from a URL')}
      <input type="url" id="urlImageInput" bind:value={urlValue} />
    </label>

    {#if userContext}
      <div class="load-from">
        <span class="label">{I18n('import from:')}</span>
        <button class="tiny-button" on:click={fetchGravatar}>Gravatar</button>
      </div>
    {/if}

    <label for="fileField">{@html icon('upload')}{I18n('from a file')}</label>
    <!-- stopEscPropagation to avoid closing the modal when escaping from the file selector menu -->
    <input
      id="fileField"
      type="file"
      accept="image/*"
      on:keyup={stopEscPropagation}
      bind:files
      bind:this={fileInput}
    />
  </div>
</div>

<div class="image-importer">
  {#if picture}
    <figure>
      {#await waitingForDataUrl}
        <Spinner />
      {:then}
        {#if dataUrl}
          <img
            class="original"
            src={dataUrl}
            alt=""
            bind:this={imageElement}
          />
        {/if}
      {/await}
    </figure>
  {/if}
</div>

<div class="buttons">
  <div class="button-group">
    <button on:click={() => dispatch('close')} class="button grey" disabled={saving || deleting}>
      {@html icon('ban')}
      {I18n('cancel')}
    </button>
    <button on:click={_deletePicture} class="button alert" disabled={saving || deleting}>
      {#if deleting}
        <Spinner />
      {:else}
        {@html icon('trash')}
      {/if}
      {I18n('delete')}
    </button>
    <button on:click={validatePicture} class="button success" disabled={saving || deleting}>
      {#if saving}
        <Spinner />
      {:else}
        {@html icon('check')}
      {/if}
      {I18n('validate')}
    </button>
  </div>
  <Flash state={flash} />
</div>

<style lang="scss">
  @import "#general/scss/utils";
  h4{
    text-align: center;
  }
  label{
    font-size: 1rem;
    margin-block: 0.5rem;
  }
  input:invalid{
    border-color: red;
  }
  .buttons{
    margin-block-start: 1em;
  }
  .image-inputs .box{
    margin: 0 auto;
    max-width: 40em;
    background-color: $light-grey;
    padding: 1em;
    @include radius;
    label:not(:first-child){
      margin-block-start: 2em;
    }
  }
  .load-from{
    @include display-flex(row, center, flex-start, wrap);
    .tiny-button{
      margin: 0.5em;
    }
  }
  .image-importer{
    padding-block-start: 1em;
    @include display-flex(column, center, center);
  }
  button:disabled{
    opacity: 0.8;
  }
</style>
