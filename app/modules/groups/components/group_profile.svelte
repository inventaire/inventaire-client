<script>
  import { i18n, I18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { userContent } from '#lib/handlebars_helpers/user_content'
  import UsersHomeSectionList from '#users/components/users_home_section_list.svelte'
  import { getAllGroupMembersDocs } from '#groups/lib/groups'
  import Flash from '#lib/components/flash.svelte'

  export let group

  let members, flash

  getAllGroupMembersDocs(group)
    .then(users => members = users)
    .catch(err => flash = err)

  const { name, description, picture, mainUserIsMember, settingsPathname, requestsCount } = group
</script>

<div class="group-profile">
  <div class="group-profile-header">
    <div class="section-one">
      <div class="cover-header">
        {#if picture}
          <div
            class="group-cover-picture"
            style:background-image="url('{imgSrc(picture, 1600)}')" />
        {/if}
        <div class="info">
          <span class="name">{name}</span>
        </div>
        <div class="iconButtons">
          {#if mainUserIsMember}
            <a
              class="showGroupSettings"
              href={settingsPathname}
              title={i18n('settings')}>
              {@html icon('cog')}
              {#if requestsCount}<span class="counter">{requestsCount}</span>{/if}
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
            class="showMembersMenu tiny-button light-blue"
            href={settingsPathname}>
            {@html icon('plus')}
            {i18n('invite')}
          </a>
        {/if}
      </div>
      <div id="membersList">
        {#if members}
          <UsersHomeSectionList
            docs={members}
            type="members" />
        {/if}
      </div>
    </div>
  </div>

  <div class="group-actions">
    <!-- {PARTIAL 'groups:group_actions' this} -->
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
    .iconButtons{
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
    .actions{
      padding-top: 1em;
      margin-bottom: 1em;
    }
    .group-cover-picture{
      @include position(absolute, 0, 0, 0, 0);
      @include bg-cover;
      width: 100%;
      @include display-flex(column, center, center);
      overflow: hidden;
    }
  }
  .section-two{
    flex: 2 0 auto;
  }
  .showGroupSettings{
    position: relative;
    .counter{
      @include counter-commons;
      @include position(absolute, 2px, 2px);
      font-size: 1rem;
      line-height: 1.1rem;
    }
  }
  .joinRequest, .requested, .cancelRequest{
    margin-top: 1em;
  }
  .requested{
    text-align: center;
    opacity: 0.8;
  }
  .description{
    padding: 0.5em;
    overflow: auto;
  }
  .showMembersMenu{
    margin: 0 1em;
  }
  #membersList{
    ul{
      max-height: 20em;
      overflow: auto;
    }
  }

  /* Small screens */
  @media screen and (max-width: $small-screen){
    .group-profile{
      @include display-flex(column, stretch, center);
    }
    .stats{
      display: none;
    }
    .section-two{
      padding: 1em;
    }
    .section-three{
      .actions{
        justify-content: center;
      }
    }
    #membersList{
      ul{
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
    h3{
      text-align: right;
      margin-right: 1em;
    }
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
      .restrictions{
        margin-top: 1em;
      }
    }
    #membersList{
      ul{
        margin-left: 0.8em;
      }
    }
  }

  /* Very Large screens */
  @media screen and (min-width: 1200px){
    .section-two{
      max-width: 70vw;
    }
  }
</style>
