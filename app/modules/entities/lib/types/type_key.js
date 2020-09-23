export default {
  pluralize(type){
    if (type.slice(-1)[0] !== 's') { type += 's'; }
    return type;
  }
};
