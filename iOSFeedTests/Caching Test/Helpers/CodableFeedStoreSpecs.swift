//
//  CodableFeedStoreSpecs.swift
//  iOSFeedTests
//
//  Created by Abdul Diallo on 4/25/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

protocol CodableFeedStoreSpecs {
    func test_retrieve_deliversEmptyCacheOnEmptyCache()
    func test_retrieve_hasNoSideEffectOnEmptyCache()
    func test_retrieveAfterInsertingOnEmptyCache_deliversNewlyInsertedCache()
    func test_retrieveAfterInsertion_hasNoSideEffectOnEmptyCache()

    func test_insert_overridesPreviouslyCacheValues()

    func test_delete_hasNoSideEffectsOnEmptyCache()
    func test_delete_esmptiesPreviouslyInsertedCache()

    func test_operation_shouldBeRunningSerially()
}

protocol FailableRetrieveFeedStoreSpecs: CodableFeedStoreSpecs {
    func test_retrieve_deliversErrorOnInvalidData()
    func test_retrieve_hasNoSideEffectOnFailure()
}

protocol FailableInsertFeedStoreSpecs: CodableFeedStoreSpecs {
    func test_insert_deliversErrorOnInsertionFailure()
    func test_insert_hasNoSideEffectOnFailure()
}

protocol FailableDeleteFeedStoreSpecs: CodableFeedStoreSpecs {
    func test_delete_deliversErrorOnDeletionError()
    func test_delete_hasNoSideEffectDeletionFailure()
}

typealias FailableSpecs = FailableRetrieveFeedStoreSpecs
    & FailableInsertFeedStoreSpecs
    & FailableDeleteFeedStoreSpecs
