import XCTest
import Combine
@testable import SwiftPropertyWrappers

private var readLog = ""
private var writeLog = ""

final class LoggedTest: XCTestCase {
  @Logged(read: { readLog += "Read: \($0)\n" },
          write: { writeLog += "Write: \($0)\n" }) var value: Int = 0
  
  private var subs: Set<AnyCancellable>!
  
  override func setUp() {
    super.setUp()
    subs = []
    readLog = ""
    writeLog = ""
  }
  
  func testBoth() throws {
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
    value = 1
    let _ = value
    value = 2
    let _ = value
    value = 3
    let _ = value
    waitForExpectations(timeout: 10)
    XCTAssertEqual(values, [1, 2, 3])
    XCTAssertEqual(readLog, "Read: 1\nRead: 2\nRead: 3\n")
    XCTAssertEqual(writeLog, "Write: 1\nWrite: 2\nWrite: 3\n")
  }
}
