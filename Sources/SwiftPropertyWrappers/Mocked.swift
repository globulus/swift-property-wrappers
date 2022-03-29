import Foundation

/// Always returns the value specified by the `mock` block.
/// The most common use case for this is to easily inject mock functionality in a single place
/// without having to modify code anywhere else.
/// While assignments don't have effect on the returned value, they are still accessible via `projectedValue`.
@propertyWrapper public struct Mocked<Value> {
  private var value: Value
  
  public let mock: () -> Value

  public init(wrappedValue: Value,
              _ mock: @escaping @autoclosure () -> Value) {
    value = wrappedValue
    self.mock = mock
  }

  public var wrappedValue: Value {
    get {
      mock()
    }
    set {
      value = newValue
    }
  }
  
  public var projectedValue: Value {
    value
  }
}
