//
//  Measurement+Codable.swift
//  Codable
//
//  Created by Sergej Jaskiewicz on 21/03/2018.
//

import Foundation

#if swift(>=3.2)
#else

@available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
extension Measurement : Codable {
    private enum CodingKeys : Int, CodingKey {
        case value
        case unit
    }

    private enum UnitCodingKeys : Int, CodingKey {
        case symbol
        case converter
    }

    private enum LinearConverterCodingKeys : Int, CodingKey {
        case coefficient
        case constant
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let value = try container.decode(Double.self, forKey: .value)

        let unitContainer = try container.nestedContainer(keyedBy: UnitCodingKeys.self, forKey: .unit)
        let symbol = try unitContainer.decode(String.self, forKey: .symbol)

        let unit: UnitType
        if UnitType.self is Dimension.Type {
            let converterContainer = try unitContainer.nestedContainer(keyedBy: LinearConverterCodingKeys.self, forKey: .converter)
            let coefficient = try converterContainer.decode(Double.self, forKey: .coefficient)
            let constant = try converterContainer.decode(Double.self, forKey: .constant)
            let unitMetaType = (UnitType.self as! Dimension.Type)
            unit = (unitMetaType.init(symbol: symbol, converter: UnitConverterLinear(coefficient: coefficient, constant: constant)) as! UnitType)
        } else {
            unit = UnitType(symbol: symbol)
        }

        self.init(value: value, unit: unit)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.value, forKey: .value)

        var unitContainer = container.nestedContainer(keyedBy: UnitCodingKeys.self, forKey: .unit)
        try unitContainer.encode(self.unit.symbol, forKey: .symbol)

        if UnitType.self is Dimension.Type {
            guard type(of: (self.unit as! Dimension).converter) is UnitConverterLinear.Type else {
                preconditionFailure("Cannot encode a Measurement whose UnitType has a non-linear unit converter.")
            }

            let converter = (self.unit as! Dimension).converter as! UnitConverterLinear
            var converterContainer = unitContainer.nestedContainer(keyedBy: LinearConverterCodingKeys.self, forKey: .converter)
            try converterContainer.encode(converter.coefficient, forKey: .coefficient)
            try converterContainer.encode(converter.constant, forKey: .constant)
        }
    }
}

#endif
