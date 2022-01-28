import XCTest
import Combine
@testable import SwiftPropertyWrappers

class CopyableItem: Copyable {
  let name: String
  let price: Int
  
  init(name: String, price: Int) {
    self.name = name
    self.price = price
  }
  
  func copy() -> Self {
    CopyableItem(name: name, price: price) as! Self
  }
}

final class CopyOnWriteTest: XCTestCase {
  @CopyOnWrite var item: CopyableItem = CopyableItem(name: "a", price: 0)
  
  func testWrapped() throws {
    let newItem = CopyableItem(name: "test", price: 1)
    item = newItem
    XCTAssertTrue(item !== newItem)
    XCTAssertEqual(item.name, newItem.name)
  }
}
