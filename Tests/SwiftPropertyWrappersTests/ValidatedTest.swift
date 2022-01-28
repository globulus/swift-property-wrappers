import XCTest
import Combine
@testable import SwiftPropertyWrappers

final class ValidatedTest: XCTestCase {
  @Validated({ $0 >= 0 }) var value: Int = 0
  
  private var subs: Set<AnyCancellable>!
  
  override func setUp() {
    super.setUp()
    subs = []
}

  func testWrapped() throws {
    XCTAssertEqual(0, value)
    value = -1
    XCTAssertEqual(0, value)
    value = 1
    XCTAssertEqual(1, value)
  }
  
  func testProjected() throws {
    var values = [Int]()
    let expectation = expectation(description: "projectedValue")
    $value
      .sink { value in
        values.append(value)
        if values.count == 3 {
          expectation.fulfill()
        }
      }
      .store(in: &subs)
    value = 0
    value = -1
    value = 1
    waitForExpectations(timeout: 10)
    XCTAssertEqual(values, [0, 0, 1])
  }
}
