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
    static func map(_ snapshots: [[String : Any?]?], storage: MapperStorage? = nil, element: ((_ object: Self) -> Void)? = nil) throws -> [Self] {
        return try Mapper.map(Self.self, snapshots: snapshots, storage: storage, element: element)
    }
}
