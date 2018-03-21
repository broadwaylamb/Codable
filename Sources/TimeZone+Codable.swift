//
//  TimeZone+Codable.swift
//  Codable
//
//  Created by Sergej Jaskiewicz on 31/07/2017.
//
//

import Foundation

#if swift(>=3.2)
#else

extension TimeZone : Codable {
    private enum CodingKeys : Int, CodingKey {
        case identifier
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let identifier = try container.decode(String.self, forKey: .identifier)

        guard let timeZone = TimeZone(identifier: identifier) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath,
                                                                    debugDescription: "Invalid TimeZone identifier."))
        }

        self = timeZone
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.identifier, forKey: .identifier)
    }
}

#endif
