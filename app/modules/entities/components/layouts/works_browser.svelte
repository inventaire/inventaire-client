<script>
  import SelectDropdown from '#components/select_dropdown.svelte'
  import Flash from '#lib/components/flash.svelte'
  import { icon } from '#lib/handlebars_helpers/icons'
  import { screen } from '#lib/components/stores/screen'
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import { I18n, i18n } from '#user/lib/i18n'
  import WorksBrowserFacets from '#entities/components/layouts/works_browser_facets.svelte'
  import WorksBrowserTextFilter from '#entities/components/layouts/works_browser_text_filter.svelte'
  import { pluck } from 'underscore'
  import WorksBrowserSection from '#entities/components/layouts/works_browser_section.svelte'

  export let sections

  const allWorks = pluck(sections, 'entities').flat()

  const displayOptions = [
    { value: 'grid', icon: 'th-large', text: I18n('grid') },
    { value: 'list', icon: 'align-justify', text: I18n('list') },
  ]

  // TODO: persist display mode in localstorage
  let displayMode = 'grid'

  let flash, facets, facetsSelectedValues, facetsSelectors, textFilterUris

  let wrapped = true
  const smallScreenThreshold = 1000
  const isNotEmpty = sections.map(_.property('uris')).flat().length > 0

  $: showControls = $screen.isLargerThan(smallScreenThreshold - 1) || !wrapped
</script>
<Flash state={flash} />
<div class="works-browser">
  <div class="wrapper" class:unwrapped={showControls}>
    {#if $screen.isSmallerThan(smallScreenThreshold) && isNotEmpty}
      <button
        class="toggle-controls"
        on:click={() => wrapped = !wrapped}
        aria-controls="works-browser-controls"
        >
        {@html icon('cog')}
        {i18n('Advanced options')}
        {#if showControls}
          {@html icon('caret-up')}
        {:else}
          {@html icon('caret-down')}
        {/if}
      </button>
    {/if}
    {#if showControls}
      {#if isNonEmptyArray(allWorks)}
        <div class="controls">
          <WorksBrowserFacets
            works={allWorks}
            bind:facets
            bind:facetsSelectors
            bind:facetsSelectedValues
            bind:flash
          />
          <WorksBrowserTextFilter bind:textFilterUris />
          <SelectDropdown bind:value={displayMode} options={displayOptions} buttonLabel={I18n('display_mode')}/>
        </div>
      {/if}
    {/if}
  </div>

  {#if sections}
    {#each sections as section}
      <WorksBrowserSection
        {section}
        {displayMode}
        {facets}
        {facetsSelectedValues}
        {textFilterUris}
        />
    {/each}
  {/if}
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .controls{
    margin-bottom: 0.5em;
    @include radius;
    padding: 0.5em;
    @include display-flex(row, center, flex-start);
    :global(.select-dropdown), :global(.dropdown-content){
      width: 10em;
    }
    :global(.select-dropdown){
      margin-right: 1em;
    }
  }

  .wrapper{
    @include display-flex(column, stretch);
    margin-top: 0.5em;
    &:not(.unwrapped){
      @include display-flex(column, flex-end);
    }
    margin-bottom: 1em;
    &.unwrapped{
      background-color: $off-white;
      .toggle-controls{
        align-self: flex-end;
      }
    }
  }
  .toggle-controls{
    z-index: 10;
    @include display-flex(row, center, center);
    @include bg-hover($off-white);
    @include radius;
    padding: 0.5em;
    color: $grey;
    :global(.fa){
      font-size: 1.4rem;
      padding: 0;
      margin: 0;
    }
  }

  /*Large screens*/
  @media screen and (min-width: $small-screen) {
    .controls{
      position: sticky;
      top: $topbar-height;
      left: 0;
      right: 0;
      z-index: 1;
      :global(.select-dropdown){
        &:last-child{
          margin-inline-start: auto;
        }
      }
    }
  }

  /*Small screens*/
  @media screen and (max-width: $small-screen) {
    .controls{
      flex-wrap: wrap;
      :global(.select-dropdown), :global(.works-browser-text-filter){
        margin: 0.5em auto;
      }
    }
  }

  /*Very small screens*/
  @media screen and (max-width: $very-small-screen) {
    .wrapper:not(.unwrapped){
      @include display-flex(column, center);
    }
  }
</style>
