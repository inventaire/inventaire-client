export default {
  setAttributes(attrs){
    if (!attrs.extract) { attrs.extract = attrs.description; }
    if (attrs.extract != null) {
      attrs.extractOverflow = attrs.extract.length > 600;
    }

  }
};
