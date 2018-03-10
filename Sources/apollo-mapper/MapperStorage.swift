//
//  MapperStorage.swift
//  apollo-mapper
//
//  Created by Evgeny Kalashnikov on 10.03.2018.
//

public protocol MapperStorage {
    func save(object: Mappable) throws
}
