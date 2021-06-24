<script>
  import app from 'app/app'
  import { I18n, i18n } from 'modules/user/lib/i18n'
  import { imgSrc } from 'lib/handlebars_helpers/images'
  import { isUserImg } from 'lib/boolean_tests'
  import log_ from 'lib/loggers'
  import PicturePicker from 'modules/general/views/behaviors/picture_picker'
  import error_ from 'lib/error'
  import { images } from 'lib/urls'

  export let currentPicture
  let pictureIsNotDefaultAvatar

  const changePicture = () => {
    app.layout.modal.show(new PicturePicker({
      context: 'user',
      pictures: app.user.get('picture'),
      save: savePicture,
      delete: deletePicture,
      crop: true,
      limit: 1
    }))
  }

  const selector = '.changePicture .loading'

  const savePicture = async pictures => {
    const picture = pictures[0]
    log_.info(picture, 'picture')
    if (!isUserImg(picture)) {
      const message = 'could not save picture: requires a local user image url'
      throw error_.new(message, pictures)
    }

    await app.request('user:update', {
      attribute: 'picture',
      value: picture,
      selector
    })
    .then(refreshPicture)
  }

  const deletePicture = async () => {
    await app.request('user:update', {
      attribute: 'picture',
      value: null,
      selector
    })
    .then(refreshPicture)
  }

  const refreshPicture = () => currentPicture = app.user.attributes.picture

  $: pictureIsNotDefaultAvatar = currentPicture !== images.defaultAvatar
</script>
<div>
  <figure>
    {#if pictureIsNotDefaultAvatar}
      <img src="{imgSrc(currentPicture, 250, 250)}" alt="{i18n('profile picture')}">
    {:else}
      {I18n('no custom picture')}
    {/if}
  </figure>
</div>

<button class="light-blue-button" tabindex="0" on:click={changePicture}>
  {#if pictureIsNotDefaultAvatar}
    {I18n('change picture')}
  {:else}
    {I18n('add a picture')}
  {/if}
</button>

<style lang="scss">
  button{
    margin-top: 1em;
  }
</style>
