//
//  MappingError.swift
//  apollo-mapper
//
//  Created by Evgeny Kalashnikov on 10.03.2018.
//

import Foundation

public enum MappingError: Error {
    case nonOptional
    case optional
    case differentTypes
    case noKey
    case customTransformationError
    case mappingError
    case notRegistered
    case another(error: Error)
    case mapperError(error: Error, snapshot: [String : Any?])
    case storageSaveError(error: Error, snapshot: [String : Any?])
}
