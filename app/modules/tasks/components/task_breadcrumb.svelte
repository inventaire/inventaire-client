<script>
  import Link from '#app/lib/components/link.svelte'
  import { icon } from '#app/lib/icons'
  import Dropdown from '#components/dropdown.svelte'
  import { getPluralType } from '#entities/lib/entities'
  import { entitiesTypesByTypes } from '#tasks/components/lib/tasks_helpers'
  import { I18n, i18n } from '#user/lib/i18n'

  export let entitiesType, type, taskId

  const menuTypes = [ 'merge', 'delete', 'deduplicate' ]

  $: menuEntitiesTypes = entitiesTypesByTypes[type]
</script>
<div class="breadcrumb">
  <Link
    url="/tasks"
    text={i18n('Tasks')}
    classNames="link"
  />
  <span class="separator">/</span>
  <Dropdown dropdownWidthBaseInEm={10}>
    <div slot="button-inner">
      {I18n(type)}
      {@html icon('chevron-down')}
    </div>
    <ul slot="dropdown-content">
      {#each menuTypes as menuType}
        <li>
          <Link
            url="/tasks/{menuType}/humans/"
            text={I18n(menuType)}
          />
        </li>
      {/each}
    </ul>
  </Dropdown>
  <span class="separator">/</span>
  <Dropdown dropdownWidthBaseInEm={10}>
    <div slot="button-inner">
      {I18n(entitiesType)}
      {@html icon('chevron-down')}
    </div>
    <ul slot="dropdown-content">
      {#each menuEntitiesTypes as menuEntitiesType}
        <li>
          <Link
            url="/tasks/{type}/{getPluralType(menuEntitiesType)}/"
            text={I18n(menuEntitiesType)}
          />
        </li>
      {/each}
    </ul>
  </Dropdown>
  {#if taskId}
    <span class="separator">/</span>
    {taskId}
  {/if}
</div>
<style lang="scss">
  @import "#general/scss/utils";
  .breadcrumb{
    @include display-flex(row, center);
    padding-inline-start: 0.5em;
    padding-block-start: 0.5em;
    padding-block-end: 0.5em;
    background-color: #f3f3f3;
    color: $grey;
    :global(.link){
      color: $grey;
    }
    :global(.dropdown-content){
      background-color: white;
      padding-block-end: 0;
      @include radius;
    }
    [slot="button-inner"]{
      @include display-flex(row, center);
      color: $grey;
      :global(.fa){
        margin-inline-start: 0.5em;
        font-size: 0.4em;
      }
    }
  }
  .separator{
    padding: 0 0.7em;
  }
  li{
    @include bg-hover-svelte(#f3f3f3);
    @include shy-border;
    :global(a){
      display: block;
      padding: 0.5em;
    }
  }
</style>
