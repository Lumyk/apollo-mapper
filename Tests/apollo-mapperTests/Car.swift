//
//  Car.swift
//  apollo-mapper
//
//  Created by Evgeny Kalashnikov on 10.03.2018.
//

import Foundation
@testable import apollo_mapper

class Car: Mappable {
    
    var id: Int
    var name: String?
    var number: String?
    var model: String
    var user: String?
    var lastUse: Date?
    
    required init(mapper: Mapper) throws {
        self.id = try mapper.value(key: "id", transformType: TransformTypes.stringToInt)
        self.name = try mapper.value(key: "car_name")
        self.number = try mapper.value(key: "number")
        self.model = try mapper.value(key: "model.name")
        self.user = try? mapper.value(key: "users.0.name")
        self.lastUse = try mapper.value(key: "last_use", transformOptionalType: { (value) -> Date? in
            guard let value = value else {
                return nil
            }
            if let value = value as? String {
                let df = DateFormatter()
                df.dateFormat = "dd-MM-yyyy"
                return df.date(from: value)
            } else {
                throw MappingError.customTransformationError
            }
        })
    }
}
