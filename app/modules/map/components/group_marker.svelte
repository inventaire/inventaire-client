<script>
  import { I18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { getGroupMembersCount, getGroupPathname, getGroupPicture } from '#groups/lib/groups'
  import { SelectInventoryOnClick } from '#users/components/lib/navs_helpers'

  export let doc
  const { name } = doc
  const picture = getGroupPicture(doc)
  const pathname = getGroupPathname(doc)
  const membersCount = getGroupMembersCount(doc)
  const onClick = SelectInventoryOnClick({ type: 'group', doc })
</script>

<a
  href={pathname}
  on:click={onClick}
  title="{name} - {I18n('group')}"
  class="objectMarker groupMarker"
>
  <div class="picture" style="background-image: url({imgSrc(picture, 100)})"></div>
  <p class="name label">{name}</p>
  <div class="members-count">{@html icon('group')} {membersCount}</div>
</a>
