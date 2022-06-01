<script>
  import AuthorDisplay from './author_display.svelte'
  export let values, authorsByUris, authorRole, prop
</script>
<div class="{authorRole} subauthors">
  {#each values as authorUri}
    <div class="author">
      <AuthorDisplay
        {prop}
        entityData={authorsByUris[authorUri]}
        {authorRole}
      />
    </div>
  {/each}
</div>
<style lang="scss">
  @import '#general/scss/utils';
  .subauthors{
    @include display-flex(row, center, flex-start, wrap);
    :not(:last-child):after{
      margin-right: 0.3em;
      content: ',';
    }
  }
  .author{
    @include display-flex(row, center, flex-start, wrap);
    :global(.entity-value){
      @include link-dark;
    }
  }
</style>
