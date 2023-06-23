<script>
  import Link from '#lib/components/link.svelte'
  import { i18n } from '#user/lib/i18n'
  import Tooltip from '#components/tooltip.svelte'
  import { getWikidataUrl } from '#entities/lib/entities'

  export let uri

  const internalUrl = `/entity/${uri}`
  const wikidataUrl = getWikidataUrl(uri)
</script>

<Tooltip>
  <div slot="primary">
    <span class="uri">{uri}</span>
  </div>
  <div slot="tooltip-content">
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
</Tooltip>

<style lang="scss">
  @import "#general/scss/utils";

  .uri{
    font-size: 0.7rem;
    font-family: sans-serif;
    color: #888;
    word-break: break-all;
  }

  /* Small screens */
  @media screen and (max-width: 700px){
    [slot="tooltip-content"]{
      @include display-flex(column);
      :global(a){
        padding: 0.5em;
      }
    }
  }

  /* Large screens */
  @media screen and (min-width: 700px){
    [slot="tooltip-content"]{
      :global(a){
        padding: 0.5em;
        &:not(:first-child){
          // Compensate for the presence of the hereafter defined separator
          padding-inline-start: 0;
          // Separator
          &::before{
            content: "|";
            padding-inline-end: 0.6em;
            // Prevent to be underlined when the .link is hovered
            text-decoration: none;
            // Hack to get text-decoration to apply: https://stackoverflow.com/a/15688237/3324977
            display: inline-block;
          }
        }
      }
    }
  }

</style>
