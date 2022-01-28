import XCTest
import Combine
@testable import SwiftPropertyWrappers

final class ClampedTest: XCTestCase {
  @Clamped(min: 10, max: 20) var minMax: Int = 10
  @Clamped(5...10) var range: Int = 5
  
  private var subs: Set<AnyCancellable>!
  
  override func setUp() {
    super.setUp()
    subs = []
}

  func testWrapped() throws {
    XCTAssertEqual(10, minMax)
    XCTAssertEqual(5, range)
    minMax = 25
    XCTAssertEqual(20, minMax)
    range = 15
    XCTAssertEqual(10, range)
    minMax = 19
    XCTAssertEqual(19, minMax)
    range = 9
    XCTAssertEqual(9, range)
  }
  
  func testProjected() throws {
    var values = [Int]()
    let expectation = expectation(description: "projectedValue")
    $minMax
      .sink { value in
        values.append(value)
        if values.count == 3 {
          expectation.fulfill()
        }
      }
      .store(in: &subs)
    minMax = 5
    minMax = 25
    minMax = 15
    waitForExpectations(timeout: 10)
    XCTAssertEqual(values, [10, 20, 15])
  }
}
