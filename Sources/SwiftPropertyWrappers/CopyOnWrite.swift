import Foundation

public protocol Copyable: AnyObject {
  func copy() -> Self
}

/// Ensures that `copy` method is invoked whenever a value is assigned instead of a usual
/// pass-by-reference assignment.
@propertyWrapper public struct CopyOnWrite<Value: Copyable> {
  private var value: Value

  public init(wrappedValue: Value) {
    value = wrappedValue
  }

  public var wrappedValue: Value {
    get {
      value
    }
    set {
      value = newValue.copy()
    }
  }
}
