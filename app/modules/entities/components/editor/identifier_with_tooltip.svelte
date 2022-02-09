<script>
  import Link from 'lib/components/link.svelte'
  import { i18n } from 'modules/user/lib/i18n'

  export let uri, contrast = false

  const internalUrl = `/entity/${uri}`

  let wikidataUrl
  if (uri.startsWith('wd:')) {
    wikidataUrl = `https://www.wikidata.org/entity/${uri.split(':')[1]}`
  }
</script>

<div class="has-tooltip" tabindex="0">
  <span class="uri">{uri}</span>
  <div class="tooltip-wrapper" role="tooltip">
    <div
      class="tooltip-content"
      class:contrast={contrast}
      >
      <Link
        url={internalUrl}
        text={i18n('see_on_website', { website: 'inventaire.io' })}
        light={true}
      />
      {#if wikidataUrl}
        <Link
          url={wikidataUrl}
          text={i18n('see_on_website', { website: 'wikidata.org' })}
          light={true}
        />
      {/if}
    </div>
  </div>
</div>

<style lang="scss">
  @import 'app/modules/general/scss/utils';

  .uri{
    font-size: 0.7rem;
    font-family: sans-serif;
    color: #888;
    // Give some room so that there is no space
    // between the uri block and the tooltip block,
    // to let the cursor be always hovering .has-tooltip
    padding-top: 1em;
  }

  .has-tooltip{
    display: inline-block;
    position: relative;
    &:not(:hover):not(:focus){
      .tooltip-wrapper{
        visibility: hidden;
      }
    }
  }
  .tooltip-wrapper{
    position: absolute;
    bottom: 130%;
    left: 50%;
    transform: translateX(-50%);
    z-index: 1;
    white-space: nowrap;
    cursor: default;
  }

  // Adapted from https://www.cssportal.com/css-tooltip-generator/
  $tooltip-bg-color: $dark-grey;
  $tooltip-contrast-bg-color: white;
  $spike-size: 0.5em;

  // The actual tooltip box shape and what's inside
  .tooltip-content{
    @include shy(0.95);
    padding: 1em;
    margin: 0 auto;
    min-width: 3em;
    text-align: center;
    color: white;
    background-color: $tooltip-bg-color;
    @include radius;

    :global(a){
      padding: 0.5em;
      &:not(:first-child){
        // Compensate for the presence of the hereafter defined separator
        padding-left: 0;
        // Separator
        &:before{
          content: '|';
          padding-right: 0.6em;
          // Prevent to be underlined when the .link is hovered
          text-decoration: none;
          // Hack to get text-decoration to apply: https://stackoverflow.com/a/15688237/3324977
          display: inline-block;
        }
      }
    }

    // Arrow
    &:after{
      content: '';
      position: absolute;
      top: 100%;
      left: 50%;
      margin-left: -$spike-size;
      width: 0;
      height: 0;
      border-top: $spike-size solid $tooltip-bg-color;
      border-right: $spike-size solid transparent;
      border-left: $spike-size solid transparent;
    }

    &.contrast{
      color: $dark-grey;
      background-color: white;
      :global(a){
        @include link-dark;
      }
      &:after{
        border-top: $spike-size solid $tooltip-contrast-bg-color;
      }
    }
  }
</style>
