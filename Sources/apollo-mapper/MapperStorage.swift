//
//  MapperStorage.swift
//  apollo-mapper
//
//  Created by Evgeny Kalashnikov on 10.03.2018.
//

public protocol MapperStorage {
    func save<T: Mappable>(object: Mapper, objectType: T.Type) throws
    func save<T: Mappable>(object: T) throws
}
