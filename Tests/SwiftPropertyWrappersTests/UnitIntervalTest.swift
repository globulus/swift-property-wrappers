import XCTest
import Combine
@testable import SwiftPropertyWrappers

final class UnitIntervalTest: XCTestCase {
  @UnitInterval(0...255) var red: CGFloat = 0
  
  private var subs: Set<AnyCancellable>!
  
  override func setUp() {
    super.setUp()
    subs = []
}

  func testWrapped() throws {
    XCTAssertEqual(0, red)
    red = 255
    XCTAssertEqual(1, red)
    red = 25.5
    XCTAssertEqual(0.1, red)
  }
  
  func testProjected() throws {
    var values = [CGFloat]()
    let expectation = expectation(description: "projectedValue")
    $red
      .sink { value in
        values.append(value)
        if values.count == 3 {
          expectation.fulfill()
        }
      }
      .store(in: &subs)
    red = 0
    red = 255
    red = 25.5
    waitForExpectations(timeout: 10)
    XCTAssertEqual(values, [0, 1, 0.1])
  }
}
