<script>
  import { i18n, I18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { getGroupMembersCount, getGroupPicture } from '#groups/lib/groups'
  import { getPicture as getUserPicture } from '#users/lib/users'
  import { createEventDispatcher } from 'svelte'

  export let doc, context, group
  const { name, username, hasItemsCount, pathname, itemsCount } = doc
  let { type = 'user' } = doc

  let picture, membersCount
  if (type === 'group') {
    membersCount = getGroupMembersCount(doc)
    picture = getGroupPicture(doc)
  } else if (type === 'user') {
    picture = getUserPicture(doc)
  }

  let userIsGroupAdmin
  if (context === 'group') {
    userIsGroupAdmin = group.admins.find(({ user }) => user === doc._id) != null
  }

  const dispatch = createEventDispatcher()
</script>

<a
  class="nav-list-element"
  href={pathname}
  on:click={() => dispatch('select', { type, doc })}
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
    top: 0;
    right: 0;
    text-align: center;
    padding: 0.2em 0;
    border-bottom-left-radius: $global-radius;
    @include transition;
  }
  .group-admin-badge{
    top: 0;
    left: 0;
    // Somehow centers the icon vertically
    line-height: 0;
    border-bottom-right-radius: $global-radius;
  }
</style>
