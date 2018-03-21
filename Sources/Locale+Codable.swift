//
//  Locale+Codable.swift
//  Codable
//
//  Created by Sergej Jaskiewicz on 31/07/2017.
//
//

import Foundation

#if swift(>=3.2)
#else

extension Locale : Codable {
    private enum CodingKeys : Int, CodingKey {
        case identifier
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let identifier = try container.decode(String.self, forKey: .identifier)
        self.init(identifier: identifier)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.identifier, forKey: .identifier)
    }
}

#endif
