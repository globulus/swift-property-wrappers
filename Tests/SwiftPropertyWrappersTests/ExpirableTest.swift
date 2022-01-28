import XCTest
import Combine
@testable import SwiftPropertyWrappers

let expirationPeriod: TimeInterval = 5

final class ExpirableTest: XCTestCase {
  @Expirable(expirationPeriod) var value: Int?
  
  func testWrapped() throws {
    XCTAssertEqual(value, nil)
    value = 10
    XCTAssertEqual(value, 10)
    Thread.sleep(forTimeInterval: expirationPeriod / 2)
    XCTAssertEqual(value, 10)
    Thread.sleep(forTimeInterval: expirationPeriod / 2)
    XCTAssertEqual(value, nil)
  }
}
