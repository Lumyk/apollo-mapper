//
//  Mappable.swift
//  apollo-mapper
//
//  Created by Evgeny Kalashnikov on 10.03.2018.
//

import Foundation

public protocol Mappable {
    init(snapshot: [String : Any?]) throws
    init(mapper: Mapper) throws
}

public extension Mappable {
    
    init(snapshot: [String : Any?]) throws {
        do {
            try self.init(mapper: Mapper(snapshot: snapshot))
        } catch let error {
            throw error
        }
    }
    
    @discardableResult
    static func map(_ snapshots: [[String : Any?]], storage: MapperStorage? = nil, exeption: ((_ error: MappingError, _ object: [String : Any?]) -> Void)? = nil, element: ((_ object: Self) -> Void)? = nil) -> [Self] {
        return Mapper.map(Self.self, snapshots: snapshots, storage: storage, exeption: exeption, element: element)
    }
}
