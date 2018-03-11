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
    init(snapshot: [String : Any?]) {
        self.snapshot = snapshot
    }
    
    @discardableResult
    public class func map<T: Mappable>(_ type: T.Type, snapshots: [[String : Any?]], store: MapperStorage? = nil, exeption: ((_ error: MappingError, _ object: [String : Any?]) -> Void)? = nil, element: ((_ object: T) -> Void)? = nil) -> [T] {
        var objects = [T]()
        for snapshot in snapshots {
            do {
                let object = try T(snapshot: snapshot)
                do {
                    try store?.save(object: object)
                } catch let error {
                    exeption?(MappingError.another(error: error), snapshot)
                    continue
                }
                element?(object)
                objects.append(object)
            } catch let error as MappingError {
                exeption?(error, snapshot)
            } catch let error {
                exeption?(MappingError.another(error: error), snapshot)
            }
        }
        return objects
    }
    
    public class func mapToStorage<T: Mappable>(_ type: T.Type, snapshots: [[String : Any?]], store: MapperStorage, exeption: ((_ error: MappingError, _ object: [String : Any?]) -> Void)? = nil) {
        for snapshot in snapshots {
            do {
                let object = try T(snapshot: snapshot)
                do {
                    try store.save(object: object)
                } catch let error {
                    exeption?(MappingError.another(error: error), snapshot)
                    continue
                }
            } catch let error as MappingError {
                exeption?(error, snapshot)
            } catch {
                exeption?(MappingError.mappingError, snapshot)
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
    
    func value<T>(key: String, transformOptionalType: ((_ value: Any?) throws -> T?)? = nil) throws -> T? {
        let keys = key.components(separatedBy: ".")
        do {
            let value = try Mapper.valueFor(ArraySlice(keys), dictionary: self.snapshot)
            if let transformType = transformOptionalType {
                return try transformType(value)
            }
            guard let value_ = value as? T? else {
                throw MappingError.differentTypes
            }
            return value_
        } catch let error as MappingError {
            throw error
        }
    }
    
    func value<T>(key: String, transformType: ((_ value: Any) throws -> T?)? = nil) throws -> T? {
        if let transformType = transformType {
            return try self.value(key: key, transformOptionalType: { (value) -> T? in
                guard let value = value else {
                    throw MappingError.optional
                }
                return try transformType(value)
            })
        }
        return try self.value(key: key, transformOptionalType: nil)
    }
    
    func value<T>(key: String, transformOptionalType: ((_ value: Any?) throws -> T)? = nil) throws -> T {
        let keys = key.components(separatedBy: ".")
        do {
            if let value = try Mapper.valueFor(ArraySlice(keys), dictionary: self.snapshot) {
                if let transformType = transformOptionalType {
                    return try transformType(value)
                }
                
                guard let value_ = value as? T else {
                    throw MappingError.differentTypes
                }
                return value_
            } else if let transformType = transformOptionalType  {
                return try transformType(nil)
            }
            throw MappingError.optional
        } catch let error as MappingError {
            throw error
        }
    }
    
    func value<T>(key: String, transformType: ((_ value: Any) throws -> T)? = nil) throws -> T {
        if let transformType = transformType {
            return try self.value(key: key, transformOptionalType: { (value) -> T in
                guard let value = value else {
                    throw MappingError.optional
                }
                return try transformType(value)
            })
        }
        return try self.value(key: key, transformOptionalType: nil)
    }
}
