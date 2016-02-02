module.exports = {
  byName: {
    map: function (doc) {
      emit(doc.name, null);
    }
  }
}