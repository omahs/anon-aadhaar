import { assert } from 'console'
import { describe } from 'mocha'
import path from 'path'

// eslint-disable-next-line @typescript-eslint/no-var-requires
const wasm_tester = require('circom_tester/wasm/tester')
// eslint-disable-next-line @typescript-eslint/no-var-requires
const { utf8 } = require('charenc')

describe('RC4 test cases', () => {
  it('testing', async () => {
    const circuit = await wasm_tester(
      path.join(__dirname, '../', 'circuits', 'rc4.circom')
    )
    const witness = await circuit.calculateWitness({
      key: utf8.stringToBytes('Key'),
      inp: utf8.stringToBytes('Plaintext'),
    })

    const out = [0xbb, 0xf3, 0x16, 0xe8, 0xd9, 0x40, 0xaf, 0x0a, 0xd3]

    for (let i = 0; i < out.length; ++i) {
      assert(witness[i + 1] == out[i])
    }
  })
})
