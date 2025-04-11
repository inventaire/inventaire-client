<script lang="ts">
  import { icon } from '#app/lib/icons'
  import { imgSrc } from '#app/lib/image_source'
  import { loadInternalLink } from '#app/lib/utils'
  import GroupActions from '#groups/components/group_actions.svelte'
  import { findMainUserInvitor } from '#groups/lib/groups'
  import { i18n, I18n } from '#user/lib/i18n'

  export let group

  const { _id: groupId, name, picture, searchable } = group
  // The group name might be changed in the settings, so group.pathname would become obsolete
  const permalink = `/groups/${groupId}`

  let invitor

  findMainUserInvitor(group)
    .then(res => invitor = res)
</script>

<div class="group-board-header">
  <a href={permalink} on:click={loadInternalLink} class="cover-link">
    {#if picture}
      <div class="group-cover-picture">
        <img src={imgSrc(picture, 540)} alt="" />
      </div>
    {/if}
    <span class="name">{name}</span>
  </a>
  {#if searchable}
    <span class="topicons searchable" title={I18n('this group appears in public search results')}>
      {@html icon('search')}
    </span>
  {:else}
    <span class="topicons not-searchable" title={I18n('only those who get the link or are invited can find this group')}>
      {@html icon('user-secret')}
    </span>
  {/if}
  {#if open}
    <span class="topicons open" title={I18n('this group is opened to membership without admin validation')}>
      {@html icon('globe')}
    </span>
  {:else}
    <span class="topicons not-open" title={I18n('this group require admins to validate new memberships')}>
      {@html icon('key')}
    </span>
  {/if}

  <div class="bottom">
    {#if invitor}
      <span class="invitor">{i18n('group_invitor', invitor)}</span>
    {/if}
    <GroupActions bind:group />
  </div>

  <a href={permalink} on:click={loadInternalLink} class="tiny-button light-blue">
    {I18n("go to the group's inventory")}
  </a>
</div>

<style lang="scss">
  @import "#general/scss/utils";

  .group-board-header{
    background-color: white;
    @include display-flex(column, center, center);
    // required to position .topicons
    position: relative;
  }
  .cover-link{
    @include display-flex(column, center, center);
    // required to position background
    position: relative;
    min-height: 6em;
    /* Large screens */
    @media screen and (width >= $small-screen){
      min-height: 10em;
    }
    width: 100%;
    font-size: 1.6em;
    .group-cover-picture{
      @include position(absolute, 0, 0, 0, 0);
      @include bg-cover;
      width: 100%;
      @include display-flex(column, center, center);
      overflow: hidden;
    }
  }
  .name{
    // Get over background image and collor-filter
    position: relative;
    margin-block-start: 0.5em;
    margin-block-end: 0.3em;
    text-align: center;
    line-height: 2rem;
  }
  .tiny-button{
    margin: 1em 0;
  }
  .bottom{
    @include display-flex(column, center, center);
    .invitor{
      font-weight: bold;
    }
  }
  .topicons{
    position: absolute;
    box-shadow: -1px 1px 5px 0 rgba(black, 0.3) inset;
    :global(.fa){
      padding: 0.5em;
      min-width: 2em;
      min-height: 2em;
      color: white;
    }
  }
  .searchable, .not-searchable{
    @include position(absolute, 0, 0);
  }
  .open, .not-open{
    @include position(absolute, 2em, 0);
    border-end-start-radius: $global-radius;
  }
  .searchable, .open{
    background-color: #ccc;
  }
  .not-searchable, .not-open{
    background-color: $dark-grey;
  }
  img{
    object-fit: cover;
    width: 100%;
    height: 100%;
  }
</style>
