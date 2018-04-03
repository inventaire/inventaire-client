should = require 'should'
__ = require '../root'
_ = require './utils_builder'
isbn_ = sharedLib 'isbn'
importers = __.require 'modules', 'inventory/lib/importers'
fs = require 'fs'
window.Papa = require 'papaparse'
iconv = require 'iconv-lite'

fixtures =
  goodreads: 'goodreads/goodreads_library_export.csv'
  librarything: 'librarythings/librarything.json'
  babelio: 'babelio/Biblio_export21507.csv'

describe 'Importers', ->
  describe 'Goodreads', ->
    { parse } = importers.goodReads
    path = __.path 'fixtures', "exports/#{fixtures.goodreads}"
    exportData = fs.readFileSync path, { encoding: 'utf-8' }

    describe 'file', ->
      it 'should return an string', (done)->
        exportData.should.be.a.String()
        done()

    describe 'parse', ->
      parsed = parse exportData
      it 'should return an array of book objects', (done)->
        parsed.should.be.a.Array()
        for doc in parsed
          doc.should.be.a.Object()
          doc.title.should.be.a.String()
          isbn_.looksLikeAnIsbn(doc.isbn).should.be.ok()
          doc.authors.should.be.a.String()
          if doc.details then doc.details.should.be.a.String()
        done()

  describe 'LibraryThing', ->
    { parse } = importers.libraryThing
    path = __.path 'fixtures', "exports/#{fixtures.librarything}"
    exportData = fs.readFileSync path, { encoding: 'utf-8' }

    describe 'file', ->
      it 'should return an string', (done)->
        exportData.should.be.a.String()
        done()

    describe 'parse', ->
      parsed = parse exportData
      it 'should return an array of book objects', (done)->
        parsed.should.be.a.Array()
        for doc in parsed
          doc.should.be.a.Object()
          doc.title.should.be.a.String()
          isbn_.looksLikeAnIsbn(doc.isbn).should.be.ok()
          doc.authors.should.be.a.String()
          if doc.notes then doc.notes.should.be.a.String()
        done()

  describe 'Babelio', ->
    { parse, encoding } = importers.babelio
    path = __.path 'fixtures', "exports/#{fixtures.babelio}"
    exportDataBuffer = fs.readFileSync path
    exportData = iconv.decode exportDataBuffer, encoding

    describe 'file', ->
      it 'should return an string', (done)->
        exportData.should.be.a.String()
        done()

    describe 'parse', ->
      parsed = parse exportData
      it 'should return an array of book objects', (done)->
        parsed.should.be.a.Array()
        for doc in parsed
          doc.should.be.a.Object()
          doc.title.should.be.a.String()
          # Some ISBN are false unfortunately
          doc.isbn.should.be.a.String()
          doc.authors.should.be.a.String()
        done()
