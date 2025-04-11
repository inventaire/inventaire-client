<script lang="ts">
  import { imgSrc } from '#app/lib/image_source'
  import type { EntityImagePath, ImageHash } from '#server/types/image'
  import { i18n } from '#user/lib/i18n'

  export let imageHash: ImageHash
  const fullResolutionUrl: EntityImagePath = `/img/entities/${imageHash}`
</script>

<a href={fullResolutionUrl} title={imageHash} target="_blank">
  <img src={imgSrc(fullResolutionUrl, 300)} alt={i18n('Image preview')} />
  <p class="image-hash">{imageHash}</p>
</a>
