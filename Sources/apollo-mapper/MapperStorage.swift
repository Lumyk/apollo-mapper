//
//  MapperStorage.swift
//  apollo-mapper
//
//  Created by Evgeny Kalashnikov on 10.03.2018.
//

public protocol MapperStorage {
    func transactionSplitter<T: Mappable>(for objectType: T.Type) -> MapperStorageTransactionSplitter
    func transaction(_ block: () throws -> Void) throws
    func save<T: Mappable>(object: Mapper, objectType: T.Type) throws
    func save<T: Mappable>(object: T) throws
    /// This methods call before saving all objects (You can clear all data before save or ignore this)
    func clearTable<T: Mappable>(for objectType: T.Type) throws
}
