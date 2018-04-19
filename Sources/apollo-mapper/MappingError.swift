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
    case notRegistered
    case another(error: Error)
    case mappingOneError(error: Error, snapshot: [String : Any?]?)
    case storageSaveOneError(error: Error, snapshot: [String : Any?]?)
    case mappingError(error: Error, snapshots: [[String : Any?]?], index: Int)
    case storageSaveError(error: Error, snapshots: [[String : Any?]?], index: Int)
}
