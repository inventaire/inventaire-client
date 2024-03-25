<script>
  import { createEventDispatcher } from 'svelte'
  import { getGroupMembersCount, getGroupPathname, getGroupPicture } from '#groups/lib/groups'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { icon } from '#lib/icons'
  import { isOpenedOutside } from '#lib/utils'
  import { I18n } from '#user/lib/i18n'

  export let doc
  const { name } = doc
  const picture = getGroupPicture(doc)
  const pathname = getGroupPathname(doc)
  const membersCount = getGroupMembersCount(doc)

  const dispatch = createEventDispatcher()

  function select (e) {
    if (!isOpenedOutside(e)) {
      dispatch('select', { type: 'user', doc })
    }
  }
</script>

<a
  href={pathname}
  on:click={select}
  title="{name} - {I18n('group')}"
  class="objectMarker groupMarker"
>
  <div class="picture" style:background-image="url({imgSrc(picture, 100)})" />
  <p class="name label">{name}</p>
  <div class="members-count">{@html icon('group')} {membersCount}</div>
</a>
