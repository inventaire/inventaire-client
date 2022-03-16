<script>
  import { I18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import preq from '#lib/preq'
  import { parseFileList } from '#lib/files'
  import { getImageHashFromDataUrl } from '#lib/images'

  export let currentValue, getInputValue, showDelete

  $: showDelete = currentValue != null

  let urlValue, files

  getInputValue = async () => {
    if (urlValue) {
      return getUrlValue()
    } else if (files) {
      const res = await getFileValue(files)
      return res
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
    const [ dataUrl ] = await parseFileList({ fileList })
    return getImageHashFromDataUrl('entities', dataUrl)
  }
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
    />
  </label>
</div>

<style>
  .wrapper{
    height: 300px;
    margin-bottom: 0.5em;
    flex: 1;
  }
  label{
    display: block;
    max-width: 25em;
    margin-bottom: 1em;
  }
  input{
    margin: 0 0.2em 0 0;
  }
  input:invalid{
    border: 2px red solid;
  }
</style>
