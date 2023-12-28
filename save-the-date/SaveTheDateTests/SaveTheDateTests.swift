//
//  SaveTheDateTests.swift
//  SaveTheDateTests
//
//  Created by JimmyChao on 2023/12/25.
//

import XCTest
import UIKit
import Foundation
@testable import save_the_date

struct MockTestingData {
    var mockModules: [PackageModule]
    var mockIndexPath: IndexPath
    var answer: Int?
}

struct MockFormattedTest {
    var mockInterval: TimeInterval
    var answer: String
}

final class SaveTheDateTests: XCTestCase {
    
    // MARK: - First test -
    let mockTestingDataA = MockTestingData(
        mockModules: [
            PackageModule(day: 0),
            PackageModule(day: 1),
            PackageModule(day: 1)],
        mockIndexPath: IndexPath(row: 0, section: 1),
        answer: Optional(1))
    
    let mockTestingDataB = MockTestingData(
        mockModules: [
            PackageModule(day: 0),
            PackageModule(day: 1),
            PackageModule(day: 2)],
        mockIndexPath: IndexPath(row: 0, section: 0),
        answer: Optional(0))

    let mockTestingDataC = MockTestingData(
        mockModules: [
            PackageModule(day: 0),
            PackageModule(day: 0),
            PackageModule(day: 0)],
        mockIndexPath: IndexPath(row: 2, section: 0),
        answer: Optional(2))
    
    func testFindModuleIndex() {
        let viewModel = CreateViewModel()
        
        let tests: [MockTestingData] = [mockTestingDataA,
                                        mockTestingDataB,
                                        mockTestingDataC]
        
        tests.forEach { test in
            let mockModules = test.mockModules
            let mockIndexPath = test.mockIndexPath
            
            let resultIndex = viewModel.findModuleIndex(
                modules: mockModules,
                from: mockIndexPath)
            
            XCTAssertEqual(resultIndex, test.answer)
        }
    }
    
    // MARK: - Second test
    
    let mockFormatingDataA = MockFormattedTest(
        mockInterval: 1703497114.205131,
        answer: "Monday 17:38:34")
    let mockFormatingDataB = MockFormattedTest(
        mockInterval: 1703410714.205131,
        answer: "Sunday 17:38:34")
    let mockFormatingDataC = MockFormattedTest(
        mockInterval: 1702892314.205131,
        answer: "Monday 17:38:34")
    
    func testShouldDismiss() {
        let tests = [mockFormatingDataA, mockFormatingDataB, mockFormatingDataC]
        
        for test in tests {
            let mockInterval = test.mockInterval
            let answer = test.answer
            
            let result = mockInterval.customFormat()
            
            XCTAssertEqual(result, answer)
        }
    }
}
