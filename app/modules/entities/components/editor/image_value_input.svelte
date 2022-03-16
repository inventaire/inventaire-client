<script>
  import { i18n, I18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import preq from '#lib/preq'
  import { getFirstFileDataUrl, resetFileInput } from '#lib/files'
  import { getImageHashFromDataUrl, getUrlDataUrl } from '#lib/images'
  import { isUrl } from '#lib/boolean_tests'
  import { imgSrc } from '#lib/handlebars_helpers/images'

  export let currentValue, getInputValue, showDelete, fileInput, property

  $: showDelete = currentValue != null

  let urlValue, files, dataUrl

  getInputValue = async () => {
    if (urlValue) {
      return getUrlValue()
    } else if (files) {
      const res = await getFileValue(files)
      return res
    } else {
      return currentValue
    }
  }

  async function getUrlValue () {
    const { hash } = await preq.post(app.API.images.convertUrl, {
      container: 'entities',
      url: urlValue,
    })
    return hash
  }

  async function getFileValue (fileList) {
    return getImageHashFromDataUrl('entities', dataUrl)
  }

  async function onUrlChange () {
    resetFileInput(fileInput)
    if (isUrl(urlValue)) {
      dataUrl = await getUrlDataUrl(urlValue)
    }
  }
  const lazyOnUrlChange = _.debounce(onUrlChange, 500)

  async function onFilesChange () {
    urlValue = null
    dataUrl = await getFirstFileDataUrl({ fileList: files })
  }

  $: urlValue && lazyOnUrlChange()
  $: files && onFilesChange()
</script>

<div class="wrapper">
  <label>
    {@html icon('link')}{I18n('from a URL')}
    <input
      type="url"
      placeholder="{I18n('enter an image url')}"
      bind:value={urlValue}
    >
  </label>

  <label>
    {@html icon('upload')}{I18n('from a file')}
    <!-- Restricting to jpeg to match the server's upload restrictions -->
    <input
      type="file"
      accept="image/jpeg"
      bind:files={files}
      bind:this={fileInput}
    />
  </label>

  {#if dataUrl}
    <img src="{dataUrl}" alt="{i18n('Image preview')}">
  {:else if currentValue}
    <img
      src={imgSrc(`/img/entities/${currentValue}`, 300, 300)}
      alt="{I18n(property)}"
    >
  {/if}
</div>

<style>
  .wrapper{
    min-height: 18em;
    margin-bottom: 0.5em;
    flex: 1;
  }
  label{
    display: block;
    max-width: 25em;
    margin-bottom: 1em;
  }
  img{
    max-height: 18em;
  }
  input{
    margin: 0 0.2em 0 0;
  }
  input:invalid{
    border: 2px red solid;
  }
</style>
