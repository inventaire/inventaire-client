<script>
  import { I18n } from '#user/lib/i18n'
  export let candidate
  let checked
  candidate.edition ? checked = true : checked = false
  $: { candidate.checked = checked }
</script>
<li class="candidateRow" class:checked>
  <div class="column checkbox">
    <input type="checkbox" bind:checked name="{I18n('select_book')}">
  </div>
  <div class="column isbn">
    {candidate.isbnData.rawIsbn}
  </div>
  <div class="column works">
    <div class="column work">
      {#if candidate.works}
        {#each candidate.works as work (work.uri)}
          <div class="column workTitle">
            {work.bestLangValue}
          </div>
          <div class="authors">
            {#if work.authors}
              {#each work.authors as author (author.uri)}
                <div class="author">
                  {author.bestLangValue}
                </div>
              {/each}
            {/if}
          </div>
        {/each}
      {/if}
    </div>
  </div>
</li>

<style lang="scss">
  @import 'app/modules/general/scss/utils';
  .column{
    flex: 20 0 0;
  }
  .candidateRow{
    @include display-flex(row, center, center);
    .checkbox{
      flex: 1 0 0;
    }
    .isbn{
      flex: 6 0 0;
    }
    margin: 0.2em 0;
    padding: 0.5em 1em;
    border: solid 1px #ccc;
    border-radius: 3px;
  }
  .checked{
    background-color: rgba($success-color, 0.3);
  }
  .work{
    @include display-flex(row, center, center);
  }
  .authors{
    @include display-flex(column, center, center);
  }
  .author{
    min-height: 2.5em;
    @include display-flex(row, center, center);
  }
  button{
    color:  white;
  }
</style>
