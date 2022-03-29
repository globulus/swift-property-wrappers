import XCTest
import Combine
@testable import SwiftPropertyWrappers

final class LazyWithResetTest: XCTestCase {
  @LazyWithReset(
      Date().timeIntervalSince1970
  ) var currentTime: TimeInterval
  
  func test() throws {
    let time = currentTime
    let time2 = currentTime
    XCTAssertEqual(time, time2)
    $currentTime.reset()
    let time3 = currentTime
    XCTAssertNotEqual(time, time3)
  }
}

final class BoundLazyWithResetTest: XCTestCase {
  var counter = 0
  @BoundLazyWithReset<BoundLazyWithResetTest, Int>({ this in
    if this.counter > 3 {
      return 5
    } else {
      return 2
    }
  }) var transformedCounter: Int
  
  func test() throws {
    $transformedCounter.receiver = self
    let c1 = transformedCounter
    let c2 = transformedCounter
    XCTAssertEqual(c1, c2)
    $transformedCounter.reset()
    counter = 4
    let c3 = transformedCounter
    XCTAssertNotEqual(c1, c3)
  }
}
