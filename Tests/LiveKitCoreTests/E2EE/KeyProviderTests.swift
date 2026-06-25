/*
 * Copyright 2026 LiveKit
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation
@testable import LiveKit
import Testing

@Suite(.serialized, .tags(.e2ee))
struct KeyProviderTests {
    @Test func setRawDataSharedKeyExportsSameBytes() throws {
        let options = KeyProviderOptions(
            sharedKey: true,
            keyRingSize: 256,
            keyDerivationAlgorithm: .hkdf,
        )
        let keyProvider = BaseKeyProvider(options: options)
        let keyData = Data([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15])
        let keyIndex: Int32 = 254

        keyProvider.setKey(data: keyData, index: keyIndex)

        let exportedKey = try #require(keyProvider.exportKey(index: keyIndex))
        #expect(exportedKey == keyData)
        #expect(keyProvider.getCurrentKeyIndex() == keyIndex)
    }

    @Test func setRawDataPerParticipantKeyExportsSameBytes() throws {
        let options = KeyProviderOptions(
            sharedKey: false,
            ratchetWindowSize: 10,
            keyRingSize: 256,
            keyDerivationAlgorithm: .hkdf,
        )
        let keyProvider = BaseKeyProvider(options: options)
        let participantId = "@alice:example.org|DEVICEID"
        let keyData = Data([15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0])
        let keyIndex: Int32 = 254

        keyProvider.setKey(data: keyData, participantId: participantId, index: keyIndex)

        let exportedKey = try #require(keyProvider.exportKey(participantId: participantId, index: keyIndex))
        #expect(exportedKey == keyData)
        #expect(keyProvider.getCurrentKeyIndex() == keyIndex)
        #expect(keyProvider.getLatestKeyIndex(participantId: participantId) == keyIndex)
    }

    @Test func stringKeyExportsUTF8Bytes() throws {
        let options = KeyProviderOptions(sharedKey: true)
        let keyProvider = BaseKeyProvider(options: options)
        let key = "shared-key"
        let expectedData = try #require(key.data(using: .utf8))

        keyProvider.setKey(key: key)

        let exportedKey = try #require(keyProvider.exportKey())
        #expect(exportedKey == expectedData)
    }
}
