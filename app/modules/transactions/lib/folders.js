export let ongoing = {
  id: 'ongoing',
  filter(transac, index, collection){ return !transac.archived; },
  icon: 'exchange',
  text: 'ongoing'
};

export let archived = {
  id: 'archived',
  filter(transac, index, collection){ return transac.archived; },
  icon: 'archive',
  text: 'archived'
};
