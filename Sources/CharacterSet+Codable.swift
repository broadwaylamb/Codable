//
//  CharacterSet+Codable.swift
//  Codable
//
//  Created by Sergej Jaskiewicz on 31/07/2017.
//
//

import Foundation

#if swift(>=3.2)
#else

extension CharacterSet : Codable {
    private enum CodingKeys : Int, CodingKey {
        case bitmap
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let bitmap = try container.decode(Data.self, forKey: .bitmap)
        self.init(bitmapRepresentation: bitmap)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.bitmapRepresentation, forKey: .bitmap)
    }
}

#endif
