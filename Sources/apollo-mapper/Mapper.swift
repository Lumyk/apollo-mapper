//
//  Maper.swift
//  apollo-mapper
//
//  Created by Evgeny Kalashnikov on 01.03.2018.
//  Copyright © 2018 Evgeny Kalashnikov. All rights reserved.
//

import Foundation

public class Mapper {
    let snapshot: [String : Any?]
    public init(snapshot: [String : Any?]) {
        self.snapshot = snapshot
    }
    
    public class func map<T: Mappable>(_ type: T.Type, snapshot: [String : Any?]?, storage: MapperStorage? = nil) throws -> T? {
        guard let snapshot = snapshot else { return nil }
        let object = try T(snapshot: snapshot)
        do {
            try storage?.save(object: object)
        } catch let error {
            throw MappingError.storageSaveError(error: error, snapshot: snapshot)
        }
        return object
    }
    
    @discardableResult
    public class func map<T: Mappable>(_ type: T.Type, snapshot: [String : Any?]?, storage: MapperStorage? = nil, storeOnly: Bool) throws -> T? {
        if let storage = storage, storeOnly {
            try Mapper.mapToStorage(type, snapshot: snapshot, storage: storage)
        } else {
            return try Mapper.map(type, snapshot: snapshot, storage: storage)
        }
        return nil
    }
    
    public class func map<T: Mappable>(_ type: T.Type, snapshots: [[String : Any?]?], storage: MapperStorage? = nil, element: ((_ object: T) -> Void)? = nil) throws -> [T] {
        var objects = [T]()
        for snapshot in snapshots {
            do {
                if let object = try self.map(type, snapshot: snapshot, storage: storage) {
                    element?(object)
                    objects.append(object)
                }
            } catch let error {
                throw MappingError.mapperError(error: error, snapshot: snapshot)
            }
        }
        return objects
    }
    
    @discardableResult
    public class func map<T: Mappable>(_ type: T.Type, snapshots: [[String : Any?]?], storage: MapperStorage? = nil, storeOnly: Bool) throws -> [T]? {
        if let storage = storage, storeOnly {
            try Mapper.mapToStorage(type, snapshots: snapshots, storage: storage)
        } else {
            return try Mapper.map(type, snapshots: snapshots, storage: storage)
        }
        return nil
    }
    
    public class func mapToStorage<T: Mappable>(_ type: T.Type, snapshot: [String : Any?]?, storage: MapperStorage) throws {
        guard let snapshot = snapshot else { return }
        let mapper = Mapper(snapshot: snapshot)
        try storage.save(object: mapper, objectType: type)
    }
    
    public class func mapToStorage<T: Mappable>(_ type: T.Type, snapshots: [[String : Any?]?], storage: MapperStorage) throws {
        for snapshot in snapshots {
            do {
                try self.mapToStorage(type, snapshot: snapshot, storage: storage)
            } catch let error {
                throw MappingError.storageSaveError(error: error, snapshot: snapshot)
            }
        }
    }
}

internal extension Mapper {
    class func valueFor(_ keys: ArraySlice<String>, dictionary: [String : Any?]) throws -> Any? {
        
        guard let keyPath = keys.first else {
            throw MappingError.noKey
        }
        
        guard let object = dictionary[keyPath] else {
            throw MappingError.noKey
        }
        
        if keys.count > 1, let dict = object as? [String: Any?] {
            let tail = keys.dropFirst()
            return try valueFor(tail, dictionary: dict)
        } else if keys.count > 1, let array = object as? [Any?] {
            let tail = keys.dropFirst()
            return try valueFor(tail, array: array)
        }
        return object
    }
    
    class func valueFor(_ keys: ArraySlice<String>, array: [Any?]) throws -> Any? {
        
        guard let keyPath = keys.first, let index = Int(keyPath), index >= 0 && index < array.count else {
            throw MappingError.noKey
        }
        
        let object = array[index]
        if keys.count > 1, let array = object as? [Any?] {
            let tail = keys.dropFirst()
            return try valueFor(tail, array: array)
        } else if  keys.count > 1, let dict = object as? [String: Any?] {
            let tail = keys.dropFirst()
            return try valueFor(tail, dictionary: dict)
        }
        return object
    }
}

public extension Mapper {
    
    func value<T>(key: String, transformOptionalType: ((_ value: Any?) throws -> T?)? = nil, type: T?.Type = T?.self) throws -> T? {
        let keys = key.components(separatedBy: ".")
        let value = try Mapper.valueFor(ArraySlice(keys), dictionary: self.snapshot)
        if let transformType = transformOptionalType {
            return try transformType(value)
        }
        guard let value_ = value as? T? else {
            throw MappingError.differentTypes
        }
        return value_
    }
    
    func value<T>(key: String, transformType: ((_ value: Any) throws -> T?)? = nil, type: T?.Type = T?.self) throws -> T? {
        if let transformType = transformType {
            return try self.value(key: key, transformOptionalType: { (value) -> T? in
                guard let value = value else {
                    throw MappingError.optional
                }
                return try transformType(value)
            }, type: type)
        }
        return try self.value(key: key, transformOptionalType: nil, type: type)
    }
    
    func value<T>(key: String, transformOptionalType: ((_ value: Any?) throws -> T)? = nil, type: T.Type = T.self) throws -> T {
        let keys = key.components(separatedBy: ".")
        if let value = try Mapper.valueFor(ArraySlice(keys), dictionary: self.snapshot) {
            if let transformType = transformOptionalType {
                return try transformType(value)
            }
            
            guard let value_ = value as? T else {
                throw MappingError.differentTypes
            }
            return value_
        } else if let transformType = transformOptionalType {
            return try transformType(nil)
        }
        throw MappingError.optional
    }
    
    func value<T>(key: String, transformType: ((_ value: Any) throws -> T)? = nil, type: T.Type = T.self) throws -> T {
        if let transformType = transformType {
            return try self.value(key: key, transformOptionalType: { (value) -> T in
                guard let value = value else {
                    throw MappingError.optional
                }
                return try transformType(value)
            }, type: type)
        }
        return try self.value(key: key, transformOptionalType: nil, type: type)
    }
}
