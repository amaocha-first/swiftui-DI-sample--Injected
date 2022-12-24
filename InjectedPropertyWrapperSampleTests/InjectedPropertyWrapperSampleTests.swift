//
//  InjectedPropertyWrapperSampleTests.swift
//  InjectedPropertyWrapperSampleTests
//
//  Created by shota-nishizawa on 2022/12/24.
//

import XCTest
@testable import InjectedPropertyWrapperSample

@MainActor
class InjectedPropertyWrapperSampleTests: XCTestCase {
    func test_networkProvider() {
        let sut = Feature()
        InjectedValues[\.networkProvider] = MockedNetworkProvider()

        sut.performDataRequest()
        XCTAssertEqual(sut.data, "mock data")
    }
}

private struct MockedNetworkProvider: NetworkProviding {
    func requestData() -> String {
        print("Data requested using the `MockedNetworkProvider`")
        return "mock data"
    }
}
