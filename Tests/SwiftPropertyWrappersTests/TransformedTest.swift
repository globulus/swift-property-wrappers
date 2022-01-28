import XCTest
import Combine
@testable import SwiftPropertyWrappers

final class TransformedTest: XCTestCase {
  @Transformed({ -$0 }) var negated: Int = 0
  @Transformed({ $0.trimmingCharacters(in: .whitespaces).lowercased() }) var formatted = ""
  
  private var subs: Set<AnyCancellable>!
  
  override func setUp() {
    super.setUp()
    subs = []
}

  func testWrapped() throws {
    negated = 5
    XCTAssertEqual(-5, negated)
    formatted = "  AbCDe  "
    XCTAssertEqual(formatted, "abcde")
  }
  
  func testProjected() throws {
    var values = [Int]()
    let expectation = expectation(description: "projectedValue")
    $negated
      .sink { value in
        values.append(value)
        if values.count == 2 {
          expectation.fulfill()
        }
      }
      .store(in: &subs)
    negated = 5
    negated = -5
    waitForExpectations(timeout: 10)
    XCTAssertEqual(values, [-5, 5])
  }
}
