import { init as onScriptReady } from './lib/config';
const { get:getLeaflet } = require('lib/get_assets')('leaflet', onScriptReady);
import PositionPicker from './views/position_picker';
import SimpleMap from './views/simple_map';

export default function() {
  app.commands.setHandlers({
    'show:position:picker:main:user': showMainUserPositionPicker,
    'show:position:picker:group': showGroupPositionPicker,
    'show:models:on:map': showModelsOnMap
  });

  return app.reqres.setHandlers({
    'prompt:group:position:picker': promptGroupPositionPicker,
    'map:before': getLeaflet
  });
};

const showPositionPicker = options => app.layout.modal.show(new PositionPicker(options));

const updatePosition = (model, updateReqres, type, focusSelector) => showPositionPicker({
  model,
  type,
  focus: focusSelector,
  resolve(newCoords, selector){
    return app.request(updateReqres, {
      attribute: 'position',
      value: newCoords,
      selector,
      // required by reqres updaters such as group:update:settings
      model
    }
    );
  }
});

var showMainUserPositionPicker = () => getLeaflet()
.then(() => updatePosition(app.user, 'user:update', 'user'));

var showGroupPositionPicker = (group, focusSelector) => getLeaflet()
.then(() => updatePosition(group, 'group:update:settings', 'group', focusSelector));

// returns a promise that should resolve with the selected coordinates
var promptGroupPositionPicker = () => getLeaflet()
.then(() => new Promise(function(resolve, reject){
  try { return showPositionPicker({ resolve, type: 'group' }); }
  catch (err) { return reject(err); }
}));

var showModelsOnMap = models => getLeaflet()
.then(() => app.layout.modal.show(new SimpleMap({ models })));
