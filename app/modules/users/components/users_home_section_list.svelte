<script lang="ts">
  import { createEventDispatcher } from 'svelte'
  import { BubbleUpComponentEvent } from '#app/lib/svelte/svelte'
  import { i18n } from '#user/lib/i18n'
  import UsersHomeSectionListLi from '#users/components/users_home_section_list_li.svelte'

  export let docs
  export let type
  export let group = null
  export let hideList = false
  export let hideListMessage = null

  const dispatch = createEventDispatcher()
  const bubbleUpComponentEvent = BubbleUpComponentEvent(dispatch)
</script>

{#if hideList}
  <p class="hidden-list-message">{hideListMessage}</p>
{:else}
  <ul class:members={type === 'members'} class="users-home-section-list">
    {#each docs as doc (doc._id)}
      <li class="user">
        <UsersHomeSectionListLi
          {doc}
          {group}
          on:select={bubbleUpComponentEvent}
        />
      </li>
    {:else}
      <li class="empty">{i18n('There is nothing here')}</li>
    {/each}
  </ul>
{/if}

<style lang="scss">
  @use "#general/scss/utils";
  ul{
    @include display-flex(row, center, flex-start, wrap);
    margin: 0 auto;
    &:not(.members){
      background-color: #f0f0f0;
      @include radius;
    }
  }
  .user{
    position: relative;
    height: $users-home-nav-avatar-size;
    width: $users-home-nav-avatar-size;
    flex: 0 0 $users-home-nav-avatar-size;
    margin: 0.2em;
    @include radius;
  }
  .hidden-list-message, .empty{
    padding: 0.5em;
    opacity: 0.8;
    font-style: italic;
    text-align: center;
    flex: 1;
  }

  /* Small screens */
  @media screen and (width < $small-screen){
    ul{
      justify-content: center;
      max-height: 15em;
      overflow-y: auto;
    }
  }
  /* Large screens */
  @media screen and (width >= $small-screen){
    ul{
      // <ul> are the elements that needs to have a scroll
      // but it's a child of .list-wrapper which is the one
      // that should have the same height as the map container
      // .list-wrapper height = <ul> height + ~4em
      // Here, 70vh correspond to $map-large-screen-heigth
      // but it seems we can't use scss variable within a css calc function
      max-height: calc(70vh - 4em);
      overflow-y: auto;
    }
  }
</style>
