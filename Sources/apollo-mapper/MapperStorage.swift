//
//  MapperStorage.swift
//  apollo-mapper
//
//  Created by Evgeny Kalashnikov on 10.03.2018.
//

public protocol MapperStorage {
    func transactionSplitter() -> MapperStorageTransactionSplitter
    func transaction(_ block: () throws -> Void) throws
    func save<T: Mappable>(object: Mapper, objectType: T.Type) throws
    func save<T: Mappable>(object: T) throws
}
