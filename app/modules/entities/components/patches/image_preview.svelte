<script lang="ts">
  import { imgSrc } from '#app/lib/handlebars_helpers/images'
  import { i18n } from '#app/modules/user/lib/i18n'
  import type { EntityImagePath, ImageHash } from '#server/types/image'

  export let imageHash: ImageHash
  const fullResolutionUrl: EntityImagePath = `/img/entities/${imageHash}`
</script>

<a href={fullResolutionUrl} title={imageHash} target="_blank">
  <img src={imgSrc(fullResolutionUrl, 300)} alt={i18n('Image preview')} />
  <p class="image-hash">{imageHash}</p>
</a>
