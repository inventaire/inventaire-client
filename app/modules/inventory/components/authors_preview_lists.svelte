<script lang="ts">
  import { imgSrc } from '#app/lib/image_source'
  import { loadInternalLink } from '#app/lib/utils'
  import type { SerializedEntity } from '#entities/lib/entities'
  import { extendedAuthorsKeys } from '#entities/lib/types/author_alt'
  import type { PropertyUri } from '#server/types/entity'
  import { I18n } from '#user/lib/i18n'

  export let authorsByProperty: Record<PropertyUri, SerializedEntity[]>
</script>

{#each Object.entries(authorsByProperty) as [ property, authors ]}
  {@const name = extendedAuthorsKeys[property]}
  {#if authors.length > 0}
    <div class="section-label {name}">
      <p class="section-label">{I18n(name)}</p>
      <ul>
        {#each authors as author}
          <li class="author-preview">
            <a
              href={author.pathname}
              title={author.label}
              on:click|stopPropagation={loadInternalLink}
            >
              <!-- using an image larger that what is displayed so that background cover scale up doesn't make the image pixelized -->
              {#if author.image?.url}
                <div class="image" style:background-image="url({imgSrc(author.image.url, 90)})"></div>
              {/if}
              <div class="summary-data">
                <span class="name" lang={author.labelLang}>{author.label}</span>
                {#if author.claims?.['wdt:P569']}
                  <p class="birth-death-dates">
                    {new Date(author.claims['wdt:P569'][0]).getUTCFullYear()}
                    &nbsp;&nbsp;-&nbsp;&nbsp;
                    {#if author.claims['wdt:P570']}
                      {new Date(author.claims['wdt:P570'][0]).getUTCFullYear()}
                    {/if}
                  </p>
                {/if}
              </div>
            </a>
          </li>
        {/each}
      </ul>
    </div>
  {/if}
{/each}

<style lang="scss">
  @import "#general/scss/utils";
  .author-preview a{
    @include radius;
    @include display-flex(row, center, flex-start);
    margin: 0.2em 0;
    @include bg-hover-svelte(#f3f3f3);
    .image{
      width: 64px;
      height: 64px;
      background-size: cover;
      background-position: center center;
      @include radius-left;
    }
    .summary-data{
      margin: 0 auto;
      text-align: center;
      .name{
        line-height: 1.2em;
        font-weight: bold;
      }
      .birth-death-dates{
        line-height: 1em;
      }
    }
  }
</style>
