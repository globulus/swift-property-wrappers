import XCTest
import Combine
@testable import SwiftPropertyWrappers

private var errorExpectation: XCTestExpectation?

func unreachable() -> Never {
  repeat {
      RunLoop.current.run()
  } while (true)
}

final class DelayedTest: XCTestCase {
  @Delayed({ _ in
    errorExpectation?.fulfill()
    unreachable()
  }) var value: String
  
  func testInvalidRead() throws {
    errorExpectation = expectation(description: "expectingFatalError")
    DispatchQueue.global(qos: .userInitiated).async {
      let _ = self.value
    }
    waitForExpectations(timeout: 10)
  }
  
  func testValidRead() throws {
    value = ""
    let read = value
    XCTAssertEqual(read, value)
  }
  
  func testProjected() throws {
    XCTAssertFalse($value)
    value = ""
    XCTAssertTrue($value)
  }
}
