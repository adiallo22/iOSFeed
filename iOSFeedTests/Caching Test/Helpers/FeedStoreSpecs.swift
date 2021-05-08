//
//  CodableFeedStoreSpecs.swift
//  iOSFeedTests
//
//  Created by Abdul Diallo on 4/25/21.
//  Copyright © 2021 Abdul Diallo. All rights reserved.
//

protocol FeedStoreSpecs {
    func test_retrieve_deliversEmptyCacheOnEmptyCache()
    func test_retrieve_hasNoSideEffectOnEmptyCache()
    func test_retrieveAfterInsertingOnEmptyCache_deliversNewlyInsertedCache()
    func test_retrieveAfterInsertion_hasNoSideEffectOnEmptyCache()

    func test_insert_overridesPreviouslyCacheValues()
    func test_insert_deliversNoErrorOnEmptyCache()
    func test_insert_deliversNoErrorOnNonEmptyCache()

    func test_delete_hasNoSideEffectsOnEmptyCache()
    func test_delete_deliversNoErrorOnNonEmptyCache()
    func test_delete_esmptiesPreviouslyInsertedCache()

    func test_operation_shouldBeRunningSerially()
}

protocol FailableRetrieveFeedStoreSpecs: FeedStoreSpecs {
    func test_retrieve_deliversErrorOnInvalidData()
    func test_retrieve_hasNoSideEffectOnFailure()
}

protocol FailableInsertFeedStoreSpecs: FeedStoreSpecs {
    func test_insert_deliversErrorOnInsertionFailure()
    func test_insert_hasNoSideEffectOnFailure()
}

protocol FailableDeleteFeedStoreSpecs: FeedStoreSpecs {
    func test_delete_deliversErrorOnDeletionError()
    func test_delete_hasNoSideEffectDeletionFailure()
}

typealias FailableSpecs = FailableRetrieveFeedStoreSpecs
    & FailableInsertFeedStoreSpecs
    & FailableDeleteFeedStoreSpecs
