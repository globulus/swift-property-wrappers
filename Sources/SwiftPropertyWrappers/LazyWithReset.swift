import Foundation

/// Allows for lazy evaluation of properties with the added option of resetting them, so that the
/// lazy initialization block runs again.
/// `projectedValue` returns the wrapper itself.
@propertyWrapper public class LazyWithReset<Value> {
  private var value: Value? = nil
  
  public let lazyInit: () -> Value
  
  public init(_ lazyInit: @escaping () -> Value) {
    self.lazyInit = lazyInit
  }

  public var wrappedValue: Value {
    get {
      if value == nil {
        value = lazyInit()
      }
      return value!
    }
  }
  
  public func reset() {
    value = nil
  }
  
  public var projectedValue: LazyWithReset<Value> {
    self
  }
}
