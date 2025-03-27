<script lang="ts">
  import app from '#app/app'
  import Flash from '#app/lib/components/flash.svelte'
  import { checkVideoInput } from '#app/lib/has_video_input'
  import { icon } from '#app/lib/icons'
  import { onChange } from '#app/lib/svelte/svelte'
  import { isOpenedOutside } from '#app/lib/utils'
  import { i18n, I18n } from '#user/lib/i18n'
  import ImportLayout from '../importer/import_layout.svelte'
  import ScanLayout from './scan_layout.svelte'
  import SearchLayout from './search_layout.svelte'

  export let tab: string
  export let isbns: string[] = null

  function onTabClick (e) {
    if (isOpenedOutside(e)) return
    const { pathname } = new URL(e.currentTarget.href)
    tab = pathname.split('/')[2]
  }

  function onTabChange () {
    app.navigate(`add/${tab}`, {
      metadata: {
        title: I18n(`title_add_layout_${tab}`),
      },
    })
    app.execute('last:add:mode:set', tab)
  }

  $: onChange(tab, onTabChange)
</script>

<div class="add-layout">
  <div class="custom-tabs">
    <div class="custom-tabs-titles">
      <a
        on:click={onTabClick}
        href="/add/search"
        class="tab"
        class:active={tab === 'search'}
        title={i18n('title_add_layout_search')}
      >
        {@html icon('search')}
        <span class="title">{I18n('search')}</span>
      </a>
      <a
        on:click={onTabClick}
        href="/add/scan"
        class="tab"
        class:active={tab === 'scan'}
        title={i18n('title_add_layout_scan')}
      >
        {@html icon('barcode')}
        <span class="title">{I18n('scan')}</span>
      </a>
      <a
        on:click={onTabClick}
        href="/add/import"
        class="tab"
        class:active={tab === 'import'}
        title={i18n('title_add_layout_import')}
      >
        {@html icon('database')}
        <span class="title">{I18n('import')}</span>
      </a>
    </div>
    <div class="custom-tabs-content">
      {#if tab === 'search'}
        <SearchLayout />
      {:else if tab === 'scan'}
        {#await checkVideoInput() then}
          <ScanLayout />
        {:catch err}
          <Flash state={err} />
        {/await}
      {:else if tab === 'import'}
        <ImportLayout {isbns} />
      {/if}
    </div>
  </div>
</div>

<style lang="scss">
  @import '#general/scss/utils';

  $custom-tab-max-width: 40em;

  .custom-tabs{
    @include display-flex(column, left);
    /* Small screens */
    @media screen and (width < $small-screen){
      width: 100%;
    }
    /* Large screens */
    @media screen and (width >= $small-screen){
      width: $custom-tab-max-width;
    }
  }
  .custom-tabs-titles{
    .title{
      @include sans-serif;
    }
    width: 100%;
    @include display-flex(row, flex-start);
    a{
      padding: 1em 0.5em;
      flex: 1;
      text-align: center;
      &.active{
        font-weight: bold;
        color: $dark-grey;
        background-color: white;
      }
      &:not(.active){
        color: white;
        @include bg-hover($dark-grey);
      }
    }
    /* Small screens */
    @media screen and (width < $custom-tab-max-width){
      flex-wrap: wrap;
      width: 100%;
      .active{
        background-color: #fafafa;
      }
      .title{
        display: none;
      }
    }
    /* Large screens */
    @media screen and (width >= $small-screen){
      a{
        &:first-child{
          border-start-start-radius: $global-radius;
        }
        &:last-child{
          border-start-end-radius: $global-radius;
        }
      }
    }
  }
  .custom-tabs-content{
    // Take the same color as the global background to let internal
    // layout sections have their own contrasting background
    background-color: $body-bg;
    width: 100%;
    @include radius-bottom;
    border-start-end-radius: $global-radius;
    /* Small screens */
    @media screen and (width < $small-screen){
      padding: 0.5em;
    }
    /* Large screens */
    @media screen and (width >= $custom-tab-max-width){
      padding: 2em;
    }
  }

  $add-layout-width: 70em;

  .add-layout{
    @include central-column($add-layout-width);
    :global(h3){
      text-align: center;
      @include sans-serif;
      color: $dark-grey;
      font-size: 1.2em;
    }
    :global(section){
      @include display-flex(column, stretch, center);
      background-color: #fefefe;
      @include radius(4px);
      @include shy-border;
      &:not(.inner){
        margin-block-start: 2em;
        margin-block-end: 2em;
      }
    }
    /* Very Small screens */
    @media screen and (width < $very-small-screen){
      :global(h3){
        margin-block-start: 1em;
      }
    }
  }
  .tab{
    :global(.fa){
      margin-inline-end: 0.5em;
    }
  }
  /* Small screens */
  @media screen and (width < $small-screen){
    .custom-tabs-content{
      // Allow scrollToElement to really get the top of the div
      // at the top of the screen
      min-height: 100vh
    }
  }
  /* Large screens */
  @media screen and (width >= $add-layout-width){
    .add-layout{
      padding: 1em;
      margin: 0 auto;
      width: $add-layout-width;
    }
    .custom-tabs-titles{
      // completing radius already added in custom_tabs
      @include radius-horizontal-group-bottom;
    }
    .custom-tabs-content{
      padding-inline-start: 0;
      padding-inline-end: 0;
    }
  }
</style>
