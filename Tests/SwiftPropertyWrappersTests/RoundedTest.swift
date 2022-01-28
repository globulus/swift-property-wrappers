import XCTest
import Combine
@testable import SwiftPropertyWrappers

final class RoundedTest: XCTestCase {
  @Rounded(0) var zero: Float = 1.1
  @Rounded(1) var one: Float = 1.15
  @Rounded(2) var two: Float = 1.125
  @Rounded(2, rule: .down) var twoDown: Float = 1.135
  
  private var subs: Set<AnyCancellable>!
  
  override func setUp() {
    super.setUp()
    subs = []
}

  func testWrapped() throws {
    XCTAssertEqual(1, zero)
    XCTAssertEqual(1.2, one)
    XCTAssertEqual(1.12, two)
    XCTAssertEqual(1.13, twoDown)
  }
  
  func testProjected() throws {
    var values = [Float]()
    let expectation = expectation(description: "projectedValue")
    $two
      .sink { value in
        values.append(value)
        if values.count == 3 {
          expectation.fulfill()
        }
      }
      .store(in: &subs)
    two = 1.112
    two = 1.125
    two = 1.135
    waitForExpectations(timeout: 10)
    XCTAssertEqual(values, [1.11, 1.12, 1.14])
  }
}
