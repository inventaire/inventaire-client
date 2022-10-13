<script>
  import { I18n } from '#user/lib/i18n'
  import { imgSrc } from '#lib/handlebars_helpers/images'

  export let doc
  const { username, picture } = doc
  const pathname = `/users/${username}/inventory`
</script>
<a
  href={pathname}
  title="{username} - {I18n('user')}">
  <div
    class="picture"
    style="background-image: url({imgSrc(picture, 100)})"
  />
  <p class="username label">
    {username}
  </p>
</a>
