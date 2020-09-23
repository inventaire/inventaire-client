import ItemShowData from './item_show_data';
import EditionsList from 'modules/entities/views/editions_list';
import showAllAuthorsPreviewLists from 'modules/entities/lib/show_all_authors_preview_lists';

export default Marionette.LayoutView.extend({
  id: 'itemShowLayout',
  className: 'standalone',
  template: require('./templates/item_show'),
  regions: {
    itemData: '#itemData',
    authors: '.authors',
    scenarists: '.scenarists',
    illustrators: '.illustrators',
    colorists: '.colorists'
  },

  behaviors: {
    General: {},
    PreventDefault: {}
  },

  initialize() {
    this.waitForEntity = this.model.grabEntity();
    return this.waitForAuthors = this.model.waitForWorks.then(getAuthorsModels);
  },

  modelEvents: {
    'grab': 'lazyRender'
  },

  serializeData() {
    const attrs = this.model.serializeData();
    attrs.works = this.model.works?.map(work => work.toJSON());
    attrs.seriePathname = getSeriePathname(this.model.works);
    return attrs;
  },

  onShow() {
    return app.execute('modal:open', 'large');
  },

  onRender() {
    this.showItemData();
    return this.waitForAuthors.then(showAllAuthorsPreviewLists.bind(this));
  },

  showItemData() { return this.itemData.show(new ItemShowData({ model: this.model })); },

  events: {
    'click .preciseEdition': 'preciseEdition'
  },

  preciseEdition() {
    const { entity } = this.model;
    if (entity.type !== 'work') { throw new Error('wrong entity type'); }

    return entity.fetchSubEntities()
    .then(() => {
      app.layout.modal.show(new EditionsList({
        collection: entity.editions,
        work: entity,
        header: 'specify the edition',
        itemToUpdate: this.model
      })
      );
      return app.execute('modal:open', 'large');
    });
  }
});

var getAuthorsModels = works => Promise.all(works)
.map(work => work.getExtendedAuthorsModels())
.reduce(aggregateAuthorsPerProperty, {});

var getSeriePathname = function(works){
  if (works?.length !== 1) { return; }
  const work = works[0];
  const seriesUris = work.get('claims.wdt:P179');
  if (seriesUris?.length === 1) {
    const [ uri, pathname ] = Array.from(work.gets('uri', 'pathname'));
    // Hacky way to get the serie entity pathname without having to request its model
    return pathname.replace(uri, seriesUris[0]);
  }
};

var aggregateAuthorsPerProperty = function(authorsPerProperty, workAuthors){
  for (let property in workAuthors) {
    const authors = workAuthors[property];
    if (authorsPerProperty[property] == null) { authorsPerProperty[property] = []; }
    authorsPerProperty[property].push(...Array.from(authors || []));
  }
  return authorsPerProperty;
};
