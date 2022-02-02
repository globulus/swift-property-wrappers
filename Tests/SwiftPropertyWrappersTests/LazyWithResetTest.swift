import XCTest
import Combine
@testable import SwiftPropertyWrappers

final class LazyWithResetTest: XCTestCase {
  @LazyWithReset({ Date().timeIntervalSince1970 }) var currentTime: TimeInterval
  
  func test() throws {
    let time = currentTime
    let time2 = currentTime
    XCTAssertEqual(time, time2)
    $currentTime.reset()
    let time3 = currentTime
    XCTAssertNotEqual(time, time3)
  }
}
