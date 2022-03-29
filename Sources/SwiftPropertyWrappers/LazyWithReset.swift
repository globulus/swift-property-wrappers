import Foundation

/// Allows for lazy evaluation of properties with the added option of resetting them, so that the
/// lazy initialization block runs again.
/// `projectedValue` returns the wrapper itself.
@propertyWrapper public class LazyWithReset<Value> {
  private var value: Value? = nil
  
  public let lazyInit: () -> Value
  
  public init(_ lazyInit: @escaping @autoclosure () -> Value) {
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

/// Allows for lazy evaluation of properties with the added option of resetting them, so that the
/// lazy initialization block runs again. The initialiation block can take a `Receiver` parameter that
/// can be set separately and allows for using `self`.
/// `projectedValue` returns the wrapper itself.
@propertyWrapper public class BoundLazyWithReset<Receiver, Value> {
  public var receiver: Receiver?
  private var value: Value? = nil
  
  public let lazyInit: (Receiver) -> Value
  
  public init(receiver: Receiver? = nil,
              _ lazyInit: @escaping (Receiver) -> Value) {
    self.receiver = receiver
    self.lazyInit = lazyInit
  }

  public var wrappedValue: Value {
    get {
      if value == nil {
        guard let receiver = receiver
        else {
          fatalError("Receiver not set before lazy init!")
        }
        value = lazyInit(receiver)
      }
      return value!
    }
  }
  
  public func reset() {
    value = nil
  }
  
  public var projectedValue: BoundLazyWithReset<Receiver, Value> {
    self
  }
}
