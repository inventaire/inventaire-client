<script>
  import SelectDropdown from '#components/select_dropdown.svelte'
  import WorkRow from '#entities/components/layouts/work_row.svelte'
  import { I18n } from '#user/lib/i18n'

  export let works

  const displayOptions = [
    { value: 'grid', icon: 'th-large', text: I18n('grid') },
    { value: 'list', icon: 'align-justify', text: I18n('list') },
  ]

  let displayMode = 'grid'

  const displayedWorks = works
</script>

<div class="works-browser">
  <div class="controls">
    <SelectDropdown bind:value={displayMode} options={displayOptions} buttonLabel={I18n('display_mode')}/>
  </div>

  <ul
    class:grid={displayMode === 'grid'}
    class:list={displayMode === 'list'}
    >
    {#each displayedWorks as work (work.uri)}
      <li>
        <WorkRow {work} {displayMode} />
      </li>
    {/each}
  </ul>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .works-browser{
    @include display-flex(row);
  }
  .controls{
    background-color: $off-white;
    @include radius;
    padding: 0.5em;
  }
  ul{
    flex: 1;
    &.list{
      max-width: 40em;
      margin: 0 auto;
    }
    &.grid{
      @include display-flex(row, center, flex-start, wrap);
    }
  }
</style>
