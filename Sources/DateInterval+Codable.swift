//
//  DateInterval+Codable.swift
//  Codable
//
//  Created by Sergej Jaskiewicz on 21/03/2018.
//

import Foundation

#if swift(>=3.2)
#else

@available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
extension DateInterval: Codable {

    private enum CodingKeys: String, CodingKey {
        case start
        case duration
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(start, forKey: .start)
        try container.encode(duration, forKey: .duration)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(start: try container.decode(Date.self, forKey: .start),
                  duration: try container.decode(TimeInterval.self, forKey: .duration))
    }
}

#endif
