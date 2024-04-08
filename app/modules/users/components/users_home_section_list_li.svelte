<script lang="ts">
  import { createEventDispatcher } from 'svelte'
  import { getGroupMembersCount, getGroupPicture } from '#groups/lib/groups'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { icon } from '#lib/icons'
  import { i18n, I18n } from '#user/lib/i18n'
  import { getPicture as getUserPicture } from '#users/lib/users'

  export let doc
  export let group = null

  const { name, username, hasItemsCount, pathname, itemsCount } = doc
  const { type = 'user' } = doc

  let picture, membersCount
  if (type === 'group') {
    membersCount = getGroupMembersCount(doc)
    picture = getGroupPicture(doc)
  } else if (type === 'user') {
    picture = getUserPicture(doc)
  }

  let userIsGroupAdmin
  if (group) {
    userIsGroupAdmin = group.admins.find(({ user }) => user === doc._id) != null
  }

  const dispatch = createEventDispatcher()

  function select () {
    dispatch('select', { type, doc })
  }
</script>

<a
  class="nav-list-element"
  href={pathname}
  on:click={select}
>
  <div class="picture" style:background-image="url({imgSrc(picture, 100)})" />
  {#if type === 'group'}
    <div class="members-count">{@html icon('group')} {membersCount}</div>
  {:else}
    {#if hasItemsCount}
      <div class="items-count" title={i18n('num_books', { smart_count: itemsCount })}>{@html icon('book')} {itemsCount}</div>
    {/if}
  {/if}

  {#if userIsGroupAdmin}
    <div class="group-admin-badge" title={I18n('group admin')}>{@html icon('cog')}</div>
  {/if}

  <div class="info">
    {#if type === 'group'}
      <strong>{name}</strong>
    {:else}
      <strong>{username}</strong>
    {/if}
  </div>
</a>

<style lang="scss">
  @import "#general/scss/utils";
  .nav-list-element{
    position: relative;
    display: block;
    height: $users-home-nav-avatar-size;
    width: $users-home-nav-avatar-size;
    .items-count, .members-count{
      opacity: 0.6;
    }
    @include radius;
    &:hover{
      .items-count, .members-count{
        opacity: 1;
      }
    }
  }
  .picture{
    background-size: cover;
    background-position: center center;
    @include position(absolute, 0, 0, 0, 0);
  }
  .info{
    @include position(absolute, null, 0, 0, 0);
    overflow: hidden;
    height: 1.6em;
    background-color: white;
    padding: 0 0.2em;
  }
  .items-count, .group-admin-badge, .members-count{
    position: absolute;
    background-color: white;
    color: $dark-grey;
    line-height: 0;
    min-width: 1em;
  }
  .items-count, .members-count{
    inset-block-start: 0;
    inset-inline-end: 0;
    text-align: center;
    padding: 0.2em 0;
    border-end-start-radius: $global-radius;
    @include transition;
  }
  .group-admin-badge{
    inset-block-start: 0;
    inset-inline-start: 0;
    // Somehow centers the icon vertically
    line-height: 0;
    border-end-end-radius: $global-radius;
  }
</style>
