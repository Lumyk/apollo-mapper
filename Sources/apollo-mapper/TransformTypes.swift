//
//  TransformTypes.swift
//  apollo-mapper
//
//  Created by Evgeny Kalashnikov on 10.03.2018.
//

import Foundation

public class TransformTypes {
    public class func stringToInt(_ value: Any) throws -> Int {
        guard let value = value as? String else {
            throw MappingError.customTransformationError
        }
        guard let intValue = Int(value) else {
            throw MappingError.customTransformationError
        }
        return intValue
    }
}
