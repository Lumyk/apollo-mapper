//
//  MapperStorageTransactionSplitter.swift
//  apollo-mapper
//
//  Created by Evgeny Kalashnikov on 19.04.2018.
//

/// Splitter for macing insert in database by 'n' transactions
///
/// - one: all mappings in one transaction (most faster but not safety, if exception don't save any anyone)
/// - split: split mapping by 'n' transactions (slower than 'one' but save all before exception, by 'n' elements)
/// - all: one mapping will be in one transaction (slow but save all before exception)
public enum MapperStorageTransactionSplitter {
    case one
    case split(by: Int)
    case all
}
