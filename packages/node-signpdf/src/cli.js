#!/usr/bin/env node

import PDFDocument from 'pdfkit'

import { SignPdf } from './signpdf'
import { pdfkitAddPlaceholderForPKCS1 } from './helpers'

import fs from 'node:fs'

const createPdf = params =>
  new Promise(resolve => {
    const requestParams = {
      placeholder: {},
      text: 'node-signpdf',
      addSignaturePlaceholder: true,
      pages: 1,
      layout: 'portrait',
      ...params,
    }

    const pdf = new PDFDocument({
      autoFirstPage: false,
      size: 'A4',
      layout: requestParams.layout,
      bufferPages: true,
    })
    pdf.info.CreationDate = ''

    if (requestParams.pages < 1) {
      requestParams.pages = 1
    }

    // Add some content to the page(s)
    for (let i = 0; i < requestParams.pages; i += 1) {
      pdf
        .addPage()
        .fillColor('#333')
        .fontSize(25)
        .moveDown()
        .text(requestParams.text)
        .save()
    }

    // Collect the ouput PDF
    // and, when done, resolve with it stored in a Buffer
    const pdfChunks = []
    pdf.on('data', data => {
      pdfChunks.push(data)
    })
    pdf.on('end', () => {
      resolve(Buffer.concat(pdfChunks))
    })

    const certBuffer = fs.readFileSync(requestParams.certFilePath)
    const cert = certBuffer.toString('hex')

    if (requestParams.addSignaturePlaceholder) {
      console.log({ ...requestParams.placeholder })
      // Externally (to PDFKit) add the signature placeholder.
      const refs = pdfkitAddPlaceholderForPKCS1({
        pdf,
        pdfBuffer: Buffer.from([pdf]),
        reason: 'I am the author',
        cert: cert,
        ...requestParams.placeholder,
      })

      // console.log(refs);
      // Externally end the streams of the created objects.
      // PDFKit doesn't know much about them, so it won't .end() them.
      Object.keys(refs).forEach(key => refs[key].end())
    }

    // Also end the PDFDocument stream.
    // See pdf.on('end'... on how it is then converted to Buffer.
    pdf.end()
  })

function signPDF({
  pdfPath,
  keyFilePath,
  certFilePath,
  passphrase = 'password',
}) {
  createPdf({
    placeholder: {
      signatureLength: 260,
    },
    text: 'This is a document',
    certFilePath: certFilePath,
  }).then(pdfBuffer => {
    console.log(pdfBuffer)
    let signer = new SignPdf()
    let key = fs.readFileSync(keyFilePath)
    const signedPdf = signer.sign_pkcs1(pdfBuffer, key, { passphrase })
    fs.writeFileSync(pdfPath, signedPdf)
  })
}

try {
  const pdfPath = process.argv[2]
  const keyFilePath = process.argv[3]
  const certFilePath = process.argv[4]
  const passphrase = process.argv[5] || undefined

  signPDF({
    pdfPath,
    keyFilePath,
    passphrase,
    certFilePath,
  })
} catch (e) {
  console.log(e)
}
