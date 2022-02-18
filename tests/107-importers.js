import 'should'
import { readFileSync } from 'fs'
import { resolve } from 'path'
import { looksLikeAnIsbn } from '#lib/isbn'
import importers from '#inventory/lib/importers'
import Papa from 'papaparse'
import iconv from 'iconv-lite'

window.Papa = Papa

const fixtures = {
  goodreads: 'goodreads/goodreads_library_export.csv',
  librarything: 'librarythings/librarything.json',
  babelio: 'babelio/Biblio_export21507.csv'
}

const fixturePath = filename => {
  return resolve(process.cwd(), `./tests/fixtures/exports/${filename}`)
}

describe('Importers', () => {
  describe('Goodreads', () => {
    const { parse } = importers.goodReads
    const path = fixturePath(fixtures.goodreads)
    const exportData = readFileSync(path, { encoding: 'utf-8' })

    describe('file', () => {
      it('should return an string', done => {
        exportData.should.be.a.String()
        done()
      })
    })

    describe('parse', () => {
      const parsed = parse(exportData)
      it('should return an array of book objects', done => {
        parsed.should.be.a.Array()
        for (const doc of parsed) {
          doc.should.be.a.Object()
          doc.title.should.be.a.String()
          looksLikeAnIsbn(doc.isbn).should.be.ok()
          doc.authors.should.be.a.Array()
          if (doc.details) doc.details.should.be.a.String()
        }
        done()
      })
    })
  })

  describe('LibraryThing', () => {
    const { parse } = importers.libraryThing
    const path = fixturePath(fixtures.librarything)
    const exportData = readFileSync(path, { encoding: 'utf-8' })

    describe('file', () => {
      it('should return an string', done => {
        exportData.should.be.a.String()
        done()
      })
    })

    describe('parse', () => {
      const parsed = parse(exportData)
      it('should return an array of book objects', done => {
        parsed.should.be.a.Array()
        for (const doc of parsed) {
          doc.should.be.a.Object()
          doc.title.should.be.a.String()
          looksLikeAnIsbn(doc.isbn).should.be.ok()
          doc.authors.should.be.a.Array()
          if (doc.notes) doc.notes.should.be.a.String()
        }
        done()
      })
    })
  })

  describe('Babelio', () => {
    const { parse, encoding } = importers.babelio
    const path = fixturePath(fixtures.babelio)
    const exportDataBuffer = readFileSync(path)
    const exportData = iconv.decode(exportDataBuffer, encoding)

    describe('file', () => {
      it('should return an string', done => {
        exportData.should.be.a.String()
        done()
      })
    })

    describe('parse', () => {
      const parsed = parse(exportData)
      it('should return an array of book objects', done => {
        parsed.should.be.a.Array()
        for (const doc of parsed) {
          doc.should.be.a.Object()
          doc.title.should.be.a.String()
          // Some ISBN are false unfortunately
          doc.isbn.should.be.a.String()
          doc.authors.should.be.a.Array()
        }
        done()
      })
    })
  })
})
