import XCTest
import Combine
@testable import SwiftPropertyWrappers

struct Item: Hashable {
  let name: String
  let price: Int
}

protocol ItemRepo {
  func fetch() -> [Item]
  func upsert(item: Item)
}

class RealRepo: ItemRepo {
  private var items = Set<Item>()
  
  func fetch() -> [Item] {
    Array(items)
  }
  
  func upsert(item: Item) {
    items.insert(item)
  }
}

class MockRepo: ItemRepo {
  static let shared = MockRepo()
  
  func fetch() -> [Item] {
    [Item(name: "test", price: 1)]
  }
  
  func upsert(item: Item) { }
}

final class MockedTest: XCTestCase {
  @Mocked({ MockRepo.shared }) var repo: ItemRepo = RealRepo()

  func testWrapped() throws {
    let fetched = repo.fetch()
    XCTAssertEqual(fetched, [Item(name: "test", price: 1)])
    repo.upsert(item: Item(name: "new", price: 2))
    let fetchedAgain = repo.fetch()
    XCTAssertEqual(fetchedAgain, fetched)
  }
  
  func testProjected() throws {
    let fetched = $repo.fetch()
    XCTAssertEqual(fetched, [])
    $repo.upsert(item: Item(name: "new", price: 2))
    let fetchedAgain = $repo.fetch()
    XCTAssertEqual(fetchedAgain, [Item(name: "new", price: 2)])
  }
}
