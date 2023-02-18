<script>
  import { i18n } from '#user/lib/i18n'
  import UsersHomeSectionListLi from '#users/components/users_home_section_list_li.svelte'

  export let docs, type
</script>

<ul class:members={type === 'members'}
>
  {#each docs as doc}
    <li class="user">
      <UsersHomeSectionListLi {doc} />
    </li>
  {:else}
    <li class="empty">{i18n('There is nothing here')}</li>
  {/each}
</ul>

<style lang="scss">
  @import "#general/scss/utils";
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
  .empty{
    padding: 0.5em;
    opacity: 0.8;
    font-style: italic;
    text-align: center;
    flex: 1;
  }

  /* Small screens */
  @media screen and (max-width: $small-screen){
    ul{
      justify-content: center;
      max-height: 15em;
      overflow-y: auto;
    }
  }
  /* Large screens */
  @media screen and (min-width: $small-screen){
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
