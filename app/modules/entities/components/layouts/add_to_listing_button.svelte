<script>
  import { i18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import Dropdown from '#components/dropdown.svelte'
  import { userListings } from '#listings/lib/stores/user_listings'

  export let entity
</script>

<div class="add-to-listing-button">
  <Dropdown
    alignDropdownWidthOnButton={true}
  >
    <div slot="button-inner">
      {@html icon('list')}
      {i18n('Add to a list')}
    </div>
    <ul slot="dropdown-content" role="menu">
      {#each $userListings as list}
        <li>
          <button
            on:click={() => alert('TODO: show a modal to add to the list, possibly with a comment')}
          >
            <!-- TODO: display a check mark if the entity is already in the list
                      This requires a new endpoint: /api/lists?action=by-creator-and-entity
            -->
            {list.name}
          </button>
        </li>
      {/each}
      <li>
        <button
          on:click={() => alert('TODO: show a modal to create a new list')}
        >
          {@html icon('plus')}
          {i18n('Create a new list')}
        </button>
      </li>
    </ul>
  </Dropdown>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .add-to-listing-button{
    :global(.dropdown-button){
      @include tiny-button($green-tree);
    }
  }
  [slot="dropdown-content"]{
    background-color: white;
    @include shy-border;
    @include display-flex(column, stretch);
    @include radius;
    overflow: hidden;
  }
  li:not(:last-child){
    border-bottom: 1px solid #ddd;
  }
  button{
    width: 100%;
    text-align: start;
    line-height: $tiny-button-line-height;
    @include tiny-button-padding;
    @include bg-hover(white, 5%);
  }
</style>
