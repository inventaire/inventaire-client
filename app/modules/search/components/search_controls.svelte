<script lang="ts">
  import { slide } from 'svelte/transition'
  import { screen } from '#app/lib/components/stores/screen'
  import { icon } from '#app/lib/icons'
  import { onChange } from '#app/lib/svelte/svelte'
  import SearchSection from '#search/components/search_section.svelte'
  import { sections } from '#search/lib/search_sections'
  import { I18n } from '#user/lib/i18n'

  export let showSearchControls = true
  export let selectedCategory = 'entity'
  export let selectedSection = 'all'
  export let results
  export let uri

  function letRoomForResults () {
    if (results?.length > 0 && $screen.isSmallerThan('$small-screen')) {
      showSearchControls = false
    } else {
      showSearchControls = true
    }
  }

  $: onChange(results, $screen, letRoomForResults)
</script>

<div class="searchSettingsTogglerWrapper">
  <button
    class="searchSettingsToggler"
    aria-controls="searchControls"
    on:click={() => showSearchControls = !showSearchControls}
  >
    {#if showSearchControls}
      {@html icon('chevron-down')}
    {:else}
      {@html icon('chevron-up')}
    {/if}
    <span class="label">{I18n('search settings')}</span>
  </button>
</div>

{#if showSearchControls && uri == null}
  <div id="searchControls" class="sections" in:slide|local>
    <div class="entitySections">
      {#each Object.entries(sections.entity) as [ sectionName, section ]}
        <SearchSection
          category="entity"
          name={sectionName}
          label={section.label}
          bind:selectedCategory
          bind:selectedSection
        />
      {/each}
    </div>
    <!-- Typo on purpose: .socialSections is blocked by this popular ad blocker list: https://secure.fanboy.co.nz/fanboy-annoyance.txt -->
    <div class="sozialSections">
      {#each Object.entries(sections.social) as [ sectionName, section ]}
        <SearchSection
          category="social"
          name={sectionName}
          label={section.label}
          bind:selectedCategory
          bind:selectedSection
        />
      {/each}
    </div>
  </div>
{/if}

<style lang="scss">
  @import "#general/scss/utils";
  .searchSettingsTogglerWrapper{
    @include display-flex(row, center, flex-end);
    display: none;
  }
  .sections{
    background-color: #eee;
  }
  .entitySections, .sozialSections{
    @include display-flex(row, flex-end, flex-start, wrap);
    text-align: center;
    overflow-x: auto;
  }
  .entitySections{
    border-block-end: 1px solid #ccc;
  }

  /* Smaller screens */
  @media screen and (width < $small-screen){
    .searchSettingsTogglerWrapper{
      margin-block-start: auto;
      @include display-flex(row, center, center);
    }
    .searchSettingsToggler{
      flex: 1 0 auto;
      height: 2.5em;
      @include display-flex(row, center, center);
      background-color: #f3f3f3;
      padding: 0.4em 0.2em;
      margin: 0.1em 1em 0;
      @include radius-top(5px);
      @include radius-bottom(0);
      :global(.fa){
        font-size: 1.5rem;
      }
      :global(.fa-chevron-up){
        @include transition(transform, 0.5s);
        margin-block-start: -0.2em;
      }
      .label{
        padding-inline: 0.2em 0.5em;
      }
    }
  }
</style>
