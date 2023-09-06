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

  export let sections = []

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
  {#if isNotEmpty}
    <div
      class="wrapper"
      class:unwrapped={showControls}
    >
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
            <SelectDropdown bind:value={displayMode} options={displayOptions} buttonLabel={I18n('display_mode')} />
          </div>
        {/if}
      {/if}
      {#if $screen.isSmallerThan(smallScreenThreshold) && isNotEmpty}
        <button
          class="toggle-controls"
          on:click={() => wrapped = !wrapped}
          aria-controls="works-browser-controls"
        >
          {#if showControls}
            {@html icon('caret-up')}
          {:else}
            {@html icon('cog')}
            {i18n('Advanced options')}
            {@html icon('caret-down')}
          {/if}
        </button>
      {/if}
    </div>
  {/if}

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
  @import "#general/scss/utils";
  .controls{
    margin-block-end: 0.5em;
    @include radius;
    padding: 0.5em;
    @include display-flex(row, space-between);
    flex: 1;
    :global(.select-dropdown), :global(.dropdown-content){
      inline-size: 10em;
    }
    :global(.select-dropdown){
      margin-inline-end: 1em;
    }
  }

  .wrapper{
    @include display-flex(row, space-between);
    margin-block: 0.5em;
    &:not(.unwrapped){
      @include display-flex(column, flex-end);
    }
    &.unwrapped{
      background-color: $off-white;
      .toggle-controls{
        align-self: flex-start;
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

  /* Large screens */
  @media screen and (min-width: $small-screen){
    .controls{
      position: sticky;
      inset-block-start: $topbar-height;
      inset-inline: 0;
      z-index: 1;
      :global(.select-dropdown){
        &:last-child{
          margin-inline-start: auto;
        }
      }
    }
  }

  /* Small screens */
  @media screen and (max-width: $small-screen){
    .controls{
      flex-wrap: wrap;
      :global(.select-dropdown), :global(.works-browser-text-filter){
        margin: 0.5em auto;
      }
    }
  }

  /* Smaller screens */
  @media screen and (width < 450px){
    .controls{
      :global(.select-dropdown), :global(.dropdown-content), :global(.works-browser-text-filter){
        margin: 0.5em;
        width: 100%;
      }
    }
    .wrapper{
      &:not(.unwrapped){
        @include display-flex(column, center, stretch);
      }
      @include display-flex(column, center, space-between);
      &.unwrapped{
        .toggle-controls{
          align-self: stretch;
        }
      }
    }
  }
</style>
