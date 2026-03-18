//
//  DashboardViewModelTests.swift
//  SportTracker
//
//  Created by Daniil Garpinich on 01.03.2026.
//

import XCTest
@testable import SportTracker

@MainActor
final class DashboardViewModelTests: XCTestCase {
    
    var viewModel: DashboardViewModel!
    var mockRepository: MockActivityRepository!
    
    override func setUp() async throws {
        try await super.setUp()
        
        mockRepository = MockActivityRepository(delayNanoseconds: 0)
        viewModel = DashboardViewModel(repository: mockRepository)
    }
    
    override func tearDown() async throws {
        viewModel = nil
        mockRepository = nil
        
        try await super.tearDown()
    }
    
    func testOnAppear_LoadsDataAndChangesStateToSuccess() async {
        viewModel.send(.onAppear)
        try? await Task.sleep(nanoseconds: 10_000_000)
        
        if case .success(let records, let filter, let warningMessage) = viewModel.state {
            XCTAssertEqual(records.count, 2)
            XCTAssertEqual(filter, .all)
            XCTAssertNil(warningMessage)
        } else {
            XCTFail("State must be .success")
        }
    }
    
    func testOnAppear_WithNetworkError_ShowsAlertAndKeepsLocalData() async {
        let localRocord = makeTestRecord(title: "Local Only", storageType: .local)
        let networkError = RepositoryError.networkError(partialData: [localRocord])
        
        mockRepository.setError(networkError)
        
        viewModel.send(.onAppear)
        try? await Task.sleep(nanoseconds: 10_000_000)
        
        if case .success(let records, let filter, let warningMessage) = viewModel.state {
            XCTAssertEqual(records.count, 1)
            XCTAssertEqual(records.first?.title, "Local Only")
            XCTAssertEqual(filter, .all)
            XCTAssertNotNil(warningMessage)
        } else {
            XCTFail("State must be .success")
        }
    }
    
    func testTapAddActivity_SetsDestinationToForm() async {
        XCTAssertNil(viewModel.destination)
        
        viewModel.send(.tapAddActivity)
        
        if case .form(let formViewModel) = viewModel.destination {
            XCTAssertNotNil(formViewModel)
        } else {
            XCTFail("Destination must be .form")
        }
    }
    
    func testDismissForm_ClearsDestinationAndReloadsData() async {
        viewModel.send(.tapAddActivity)
        XCTAssertNotNil(viewModel.destination)
        
        viewModel.send(.dissmissForm)
        try? await Task.sleep(nanoseconds: 10_000_000)
        
        XCTAssertNil(viewModel.destination)
        
        if case .success(let records, let filter, let warningMessage) = viewModel.state {
            XCTAssertEqual(filter, .all)
            XCTAssertNil(warningMessage)
            XCTAssertEqual(records.count, 2)
        } else {
            XCTFail("State must be .success")
        }
    }
    
    func testSetFilter_UpdatesStateWithFilteredRecords() async {
        let localRecord = makeTestRecord(title: "Local Run", storageType: .local)
        let remoteRecord = makeTestRecord(title: "Remote Run", storageType: .remote)
        await mockRepository.setRecords([localRecord, remoteRecord])
        
        viewModel.send(.onAppear)
        try? await Task.sleep(nanoseconds: 10_000_000)
        
        viewModel.send(.setFilter(.local))
        
        if case .success(let records, let filter, _) = viewModel.state {
            XCTAssertEqual(filter, .local)
            XCTAssertEqual(records.count, 1)
            XCTAssertEqual(records.first?.title, "Local Run")
        } else {
            XCTFail("State must be .success")
        }
    }
    
    func testDismissWarningAlert_RemovesWarningButKeepsData() async {
        let localRocord = makeTestRecord(title: "Local Only", storageType: .local)
        let networkError = RepositoryError.networkError(partialData: [localRocord])
        
        mockRepository.setError(networkError)
        
        viewModel.send(.onAppear)
        try? await Task.sleep(nanoseconds: 10_000_000)
        
        if case .success(_, _, let warning) = viewModel.state {
            XCTAssertNotNil(warning)
        }
        
        viewModel.send(.dismissWarningAlert)
        
        if case .success(let records, let filter, let warningMessage) = viewModel.state {
            XCTAssertEqual(records.count, 1)
            XCTAssertEqual(filter, .all)
            XCTAssertNil(warningMessage)
        } else {
            XCTFail("State must be .success")
        }
    }
    
    private func makeTestRecord(title: String = "Test Run", storageType: StorageType = .local ) -> ActivityRecord {
        ActivityRecord(
            title: title,
            location: "Test Location",
            durationInMinutes: 30,
            date: Date(),
            storageType: storageType
        )
    }
}
