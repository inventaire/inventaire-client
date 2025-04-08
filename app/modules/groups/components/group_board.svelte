<script lang="ts">
  import { slide } from 'svelte/transition'
  import FoldableSection from '#components/foldable_section.svelte'
  import GroupBoardHeader from '#groups/components/group_board_header.svelte'
  import GroupMembers from '#groups/components/group_members.svelte'
  import GroupRequests from '#groups/components/group_requests.svelte'
  import GroupSettings from '#groups/components/group_settings.svelte'
  import InviteUsers from '#groups/components/invite_users.svelte'
  import { I18n } from '#user/lib/i18n'
  import InviteByEmail from '#users/components/invite_by_email.svelte'

  export let group
  export let standalone = true

  const { mainUserIsAdmin, mainUserIsMember } = group
</script>

<!-- TODO: Display sections in a wrappable flex row, to better use large screens  -->
<div class="group-board" class:standalone>
  <div class="header">
    <GroupBoardHeader {group} />
  </div>
  <div class="body">
    {#if mainUserIsAdmin && group.requested.length > 0}
      <section transition:slide>
        <FoldableSection icon="inbox" summary={I18n('requests waiting your approval')} open={true}>
          <GroupRequests bind:group />
        </FoldableSection>
      </section>
    {/if}
    <section>
      <FoldableSection icon="cog" summary={I18n('group settings')}>
        <GroupSettings bind:group />
      </FoldableSection>
    </section>
    <section>
      <FoldableSection icon="users" summary={I18n('members')}>
        <GroupMembers bind:group />
      </FoldableSection>
    </section>
    {#if mainUserIsMember}
      <section>
        <FoldableSection icon="plus" summary={I18n('invite new members')}>
          <InviteUsers bind:group />
        </FoldableSection>
      </section>
      <section>
        <FoldableSection icon="envelope" summary={I18n('invite by email')}>
          <InviteByEmail bind:group />
        </FoldableSection>
      </section>
    {/if}
  </div>
</div>

<style lang="scss">
  @use "#general/scss/utils";
  .group-board{
    @include display-flex(column, center, center);
    margin-block-end: 1em;
    @include shy-border-vertical-group;
    /* Large screens */
    @media screen and (width >= $small-screen){
      margin: 0 1em 1em;
      padding: 0 1em 1em;
    }
    section, > div{
      width: 100%;
      max-width: 40em;
    }
  }
  .header, .body{
    background-color: white;
  }
  .header{
    @include radius-top;
  }
  .body{
    @include radius-bottom;
    padding: 0 1em 1em;
  }
  section{
    &:not(:last-child){
      margin-block-end: 1em;
    }
    @include radius;
    background-color: #f2f2f2;
  }
</style>
