<script>
	export let entity
const { uri, label, description } = entity
</script>
<div class="entity-element">
  <div class="top">
    <span class="label">{label}</span>
    <a
      class="uri"
      href="/entity/{uri}"
      target="_blank"
      on:click|stopPropagation
    >
      {uri}
    </a>
  </div>
  <div class="bottom">
    {#if description}<span class="description">{description}</span>{/if}
  </div>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .entity-element{
    @include display-flex(column, flex-start, flex-start, wrap);
  }
  .label{
    padding-right:1em;
  }
  .top{
  	@include display-flex(row, center, flex-start, wrap);
  }
  .description{
    color: $grey;
    margin-right: 1em;
  }
</style>
