import { findNextActions, isArchived } from './transactions';
import infoPartials from './info_partials';
import actionsData from './actions_data';

const getNextActionsData = function(transaction){
  const nextActions = proxyFindNextActions(transaction);
  let data = actionsData()[nextActions];
  if (data == null) { return; }
  data = addTransactionInfo(data, transaction);
  return grabOtherUsername(transaction, data);
};

// TODO: remove the adapter now that the lib isn't shared with the server anymore
var proxyFindNextActions = transaction => findNextActions(sharedLibAdapter(transaction));

var sharedLibAdapter = transaction => ({
  name: transaction.get('transaction'),
  state: transaction.get('state'),
  mainUserIsOwner: transaction.mainUserIsOwner
});

var addTransactionInfo = function(data, transaction){
  const transactionMode = transaction.get('transaction');
  return data.map(function(action){
    action[transactionMode] = true;
    action.itemId = transaction.get('item');
    const infoData = infoPartials[transactionMode][action.text];
    if (infoData != null) { _.extend(action, infoData); }
    return action;
  });
};

var grabOtherUsername = function(transaction, actions){
  const username = transaction.otherUser()?.get('username');
  return actions.map(action => _.extend({}, action, { username }));
};

export default {
  getNextActionsData,
  isArchived(transaction){ return isArchived(sharedLibAdapter(transaction)); }
};
