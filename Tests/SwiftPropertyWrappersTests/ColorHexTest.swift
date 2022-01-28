import XCTest
import SwiftUI
@testable import SwiftPropertyWrappers

final class ColorHexTest: XCTestCase {
  @ColorHex var colorHex = "fff"
  
  func testProjected() throws {
    XCTAssertEqual(Color(white: 1), $colorHex!)
    colorHex = "FF0000"
    XCTAssertEqual(Color(red: 1, green: 0, blue: 0), $colorHex!)
    colorHex = "fail"
    XCTAssertEqual(nil, $colorHex)
  }
}
