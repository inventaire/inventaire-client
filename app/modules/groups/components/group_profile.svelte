<script>
  import { i18n, I18n } from '#user/lib/i18n'
  import { icon, isOpenedOutside, loadInternalLink } from '#lib/utils'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { userContent } from '#lib/handlebars_helpers/user_content'
  import GroupActions from '#groups/components/group_actions.svelte'
  import UsersHomeSectionList from '#users/components/users_home_section_list.svelte'
  import { getAllGroupMembersDocs, serializeGroup } from '#groups/lib/groups'
  import Flash from '#lib/components/flash.svelte'
  import Spinner from '#components/spinner.svelte'

  export let group

  let members, flash

  const waitForMembers = getAllGroupMembersDocs(group)
    .then(users => members = users)
    .catch(err => flash = err)

  const { name, description, requested } = group
  let settingsPathname, mainUserIsMember, mainUserIsAdmin, picture
  $: ({ settingsPathname, mainUserIsMember, mainUserIsAdmin, picture } = serializeGroup(group))

  function showMembersMenu (e) {
    if (isOpenedOutside(e)) return
    app.execute('show:group:board', group, { openedSection: 'groupInvite' })
    e.preventDefault()
  }
</script>

<div class="group-profile">
  <div class="group-profile-header">
    <div class="section-one">
      <div class="cover-header">
        {#if picture}
          <img class="cover-image" src={imgSrc(picture, 1600)} alt="" />
        {/if}
        <div class="info">
          <span class="name">{name}</span>
        </div>
        <div class="icon-buttons">
          {#if mainUserIsMember}
            <a
              class="show-group-settings"
              href={settingsPathname}
              title={i18n('settings')}
              on:click={loadInternalLink}
            >
              {@html icon('cog')}
              {#if mainUserIsAdmin && requested.length > 0}
                <span class="counter">{requested.length}</span>
              {/if}
            </a>
          {/if}
        </div>
      </div>
      {#if description}
        <p class="description">{@html userContent(description)}</p>
      {/if}
    </div>

    <div class="section-two">
      <div class="list-label-wrapper">
        <p class="list-label">{I18n('members')}</p>
        {#if mainUserIsMember}
          <a
            class="show-members-menu tiny-button light-blue"
            href={settingsPathname}
            on:click={showMembersMenu}
          >
            {@html icon('plus')}
            {i18n('invite')}
          </a>
        {/if}
      </div>
      <div class="members-list">
        {#await waitForMembers}
          <Spinner />
        {:then}
          <UsersHomeSectionList docs={members} type="members" />
        {/await}
      </div>
    </div>
  </div>

  <div class="group-actions">
    <GroupActions bind:group />
  </div>
</div>

<Flash state={flash} />

<style lang="scss">
  @import "#general/scss/utils";
  .group-profile{
    background-color: #eee;
    margin: 0.5em 0;
  }
  .section-one{
    flex: 1 0 auto;
  }
  .cover-header{
    max-width: 100%;
    @include display-flex(column, center, center);
    height: 18em;
    position: relative;
  }
  .icon-buttons{
    @include position(absolute, 3px, 3px);
    @include display-flex(column, center, space-between);
    @include radius;
    font-size: 1.4em;
    a{
      padding: 0.3em;
      @include bg-hover($coverTextBg);
      :global(.fa){
        color: white;
        width: 2em;
        text-align: center;
      }
    }
  }
  .info{
    // Somehow needed to make it appear above group-cover-picture and picture-color-filter
    position: relative;
    align-self: stretch;
    @include display-flex(column, center, center);
    color: white;
    :global(.fa){
      color: white;
    }
    flex: 1;
  }
  .cover-image{
    @include position(absolute, 0, 0, 0, 0);
  }
  .section-two{
    flex: 2 0 auto;
  }
  .show-group-settings{
    position: relative;
    .counter{
      @include counter-commons;
      @include position(absolute, 2px, 2px);
      font-size: 1rem;
      line-height: 1.1rem;
    }
  }
  .description{
    padding: 0.5em;
    overflow: auto;
  }
  .show-members-menu{
    margin: 0 1em;
  }
  .members-list{
    max-height: 20em;
    overflow: auto;
  }
  .name{
    text-align: center;
    font-size: 1.5em;
    @include text-wrap;
    max-width: 100%;
    color: white;
    margin: auto;
    font-weight: bold;
    @include serif;
    padding: 0.5em 1em;
    @include radius;
    background-color: rgba($dark-grey, 0.9);
    max-height: 3em;
  }
  .group-actions{
    :global(button){
      margin-top: 1em;
      margin-bottom: 1em;
    }
    :global(.requested){
      text-align: center;
      opacity: 0.8;
    }
  }

  /* Small screens */
  @media screen and (max-width: $small-screen){
    .group-profile{
      @include display-flex(column, stretch, center);
    }
    .section-two{
      padding: 1em;
    }
    .members-list{
      :global(.users-home-section-list){
        justify-content: flex-start;
      }
    }
    .description{
      max-height: 10em;
      padding: 0.5em;
    }
  }

  /* Large screens */
  @media screen and (min-width: $small-screen){
    .group-profile-header{
      @include display-flex(row, flex-start, space-between);
    }
    .section-one{
      flex: 1 0 20em;
      max-width: 50%;
    }
    .section-two{
      flex: 5 0 0;
      .list-label{
        text-align: right;
        margin: 0.5em 1em;
      }
    }
    .group-actions{
      @include display-flex(column, center, center);
      margin-top: 1em;
      :global(.restrictions){
        margin-top: 1em;
      }
    }
    .members-list{
      margin-left: 0.8em;
    }
  }

  /* Very Large screens */
  @media screen and (min-width: 1200px){
    .section-two{
      max-width: 70vw;
    }
  }
</style>
