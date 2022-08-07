<script>
  import { I18n } from '#user/lib/i18n'
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import screen_ from '#lib/screen'
  import Spinner from '#general/components/spinner.svelte'
  import { getEntitiesByUris } from '#entities/lib/entities'
  import ListSelections from './list_selections.svelte'
  import ListInfoBox from '#modules/lists/components/list_info_box.svelte'
  export let list, selections

  let { _id, creator } = list

  // TODO: rebase and fix visibility once items/shelves visibility branches have been merged
  // let { visibility } = list
  // const listings = app.user.listings()
  // let visibilityData = listings[visibility]

  let isEditable = creator === app.user.id
  let entities = []

  const paginationSize = 5
  let offset = 5
  let fetching
  // fake
  let scrollY = 0

  const getSelectionsEntities = async selections => {
    const uris = selections.map(_.property('uri'))
    return getEntitiesByUris(uris)
  }

  const assignFirstSelectionsAsEntities = async () => {
    const firstSelections = selections.slice(0, paginationSize)
    entities = await getSelectionsEntities(firstSelections)
  }

  const waitingForEntities = assignFirstSelectionsAsEntities()

  const fetchMore = async () => {
    if (fetching || hasMore === false) return
    fetching = true
    const nextBatchSelections = selections.slice(offset, paginationSize)
    const nextEntities = await getSelectionsEntities(nextBatchSelections)
    if (isNonEmptyArray(nextEntities)) {
      offset += paginationSize
      entities = [ entities, ...nextEntities ]
    }
    fetching = false
  }

  $: {
    if (screen_.height() >= scrollY) {
      fetchMore()
    }
  }
  $: hasMore = entities.length > offset
</script>

<div class="list-layout">
  <ListInfoBox {list} />
  {#await waitingForEntities}
    <Spinner center={true} />
  {:then}
    <ListSelections
      bind:entities
      listId={_id}
      {isEditable}
    />
  {/await}
</div>

<div class="footer">
  <p class="list-id">
    {I18n('list')}
      -
    {_id}
  </p>
</div>

<style lang="scss">
  @import '#general/scss/utils';
 .list-layout{
   @include display-flex(column, center);
 }
 .list-id{
 	@include display-flex(column, center);
 	font-size: small;
 }
</style>
