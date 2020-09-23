import should from 'should';
import __ from '../root';
import _ from './utils_builder';
const { looksLikeAnIsbn } = __.require('lib', 'isbn');
const importers = __.require('modules', 'inventory/lib/importers');
import fs from 'fs';
window.Papa = require('papaparse');
const iconv = require('iconv-lite');

const fixtures = {
  goodreads: 'goodreads/goodreads_library_export.csv',
  librarything: 'librarythings/librarything.json',
  babelio: 'babelio/Biblio_export21507.csv'
};

describe('Importers', function() {
  describe('Goodreads', function() {
    const { parse } = importers.goodReads;
    const path = __.path('fixtures', `exports/${fixtures.goodreads}`);
    const exportData = fs.readFileSync(path, { encoding: 'utf-8' });

    describe('file', () => it('should return an string', function(done){
      exportData.should.be.a.String();
      return done();
    }));

    return describe('parse', function() {
      const parsed = parse(exportData);
      return it('should return an array of book objects', function(done){
        parsed.should.be.a.Array();
        for (let doc of parsed) {
          doc.should.be.a.Object();
          doc.title.should.be.a.String();
          looksLikeAnIsbn(doc.isbn).should.be.ok();
          doc.authors.should.be.a.Array();
          if (doc.details) { doc.details.should.be.a.String(); }
        }
        return done();
      });
    });
  });

  describe('LibraryThing', function() {
    const { parse } = importers.libraryThing;
    const path = __.path('fixtures', `exports/${fixtures.librarything}`);
    const exportData = fs.readFileSync(path, { encoding: 'utf-8' });

    describe('file', () => it('should return an string', function(done){
      exportData.should.be.a.String();
      return done();
    }));

    return describe('parse', function() {
      const parsed = parse(exportData);
      return it('should return an array of book objects', function(done){
        parsed.should.be.a.Array();
        for (let doc of parsed) {
          doc.should.be.a.Object();
          doc.title.should.be.a.String();
          looksLikeAnIsbn(doc.isbn).should.be.ok();
          doc.authors.should.be.a.Array();
          if (doc.notes) { doc.notes.should.be.a.String(); }
        }
        return done();
      });
    });
  });

  return describe('Babelio', function() {
    const { parse, encoding } = importers.babelio;
    const path = __.path('fixtures', `exports/${fixtures.babelio}`);
    const exportDataBuffer = fs.readFileSync(path);
    const exportData = iconv.decode(exportDataBuffer, encoding);

    describe('file', () => it('should return an string', function(done){
      exportData.should.be.a.String();
      return done();
    }));

    return describe('parse', function() {
      const parsed = parse(exportData);
      return it('should return an array of book objects', function(done){
        parsed.should.be.a.Array();
        for (let doc of parsed) {
          doc.should.be.a.Object();
          doc.title.should.be.a.String();
          // Some ISBN are false unfortunately
          doc.isbn.should.be.a.String();
          doc.authors.should.be.a.Array();
        }
        return done();
      });
    });
  });
});
