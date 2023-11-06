import assert from 'assert'

// eslint-disable-next-line @typescript-eslint/no-var-requires
const { utf8 } = require('charenc')
// eslint-disable-next-line @typescript-eslint/no-var-requires
const wasm_tester = require('circom_tester/wasm/tester')
// eslint-disable-next-line @typescript-eslint/no-var-requires
const crypt = require('crypt')
// eslint-disable-next-line @typescript-eslint/no-var-requires
const { bytesToWords } = require('crypt')

import md5 from 'md5'
import path from 'path'

describe('Md5 circuit', function () {
  it('md5 hash function', async function () {
    const hash = md5('They are deterministic')
    const circuit = await wasm_tester(
      path.join(__dirname, '../', 'circuits', 'md5.circom')
    )

    const bytes = utf8.stringToBytes('They are deterministic')

    const m = bytesToWords(bytes)
    const l = bytes.length * 8

    for (let i = 0; i < m.length; i++) {
      m[i] =
        (((m[i] << 8) | (m[i] >>> 24)) & 0x00ff00ff) |
        (((m[i] << 24) | (m[i] >>> 8)) & 0xff00ff00)
      // eslint-disable-next-line no-self-assign
      m[i] = m[i] >>> 0
    }
    m[l >>> 5] |= 0x80 << (bytes.length * 8) % 32

    while (m.length % 14 != 0) {
      m.push(0)
    }
    m.push(bytes.length * 8)
    m.push(0)

    for (let i = 0; i < m.length; ++i) {
      m[i] = m[i] >>> 0
    }

    const witness = await circuit.calculateWitness({
      m: m,
    })

    const hash_bytes = crypt.hexToBytes(hash)
    let h = witness[1]
    for (let i = 15; i >= 0; --i) {
      assert(BigInt(hash_bytes[i]) == h % BigInt(256))
      h = h >> BigInt(8)
    }
  })
})
