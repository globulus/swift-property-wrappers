import Foundation

/// Allows for late initialization of properties, thus working around Swift's init safety checks.
/// This can avoid the need for implicitly-unwrapped optionals in multi-phase initialization.
/// `projectedValue` returns true if the value is already set.
@propertyWrapper public struct Delayed<Value> {
  private var value: Value? = nil
  
  public let failureHandler: (String) -> Never
  
  public init(_ failureHandler: @escaping (String) -> Never = { fatalError($0) }) {
    self.failureHandler = failureHandler
  }

  public var wrappedValue: Value {
    get {
      guard let value = value
      else {
        failureHandler("Property accessed before being initialized!")
      }
      return value
    }
    set {
      value = newValue
    }
  }
  
  public var projectedValue: Bool {
    value != nil
  }
}
