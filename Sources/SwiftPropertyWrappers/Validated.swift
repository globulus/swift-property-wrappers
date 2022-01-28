import Foundation
import Combine

/// Only sets the new value is it passes validation by the provided blocks. Allows for vetoing new values.
/// `projectedValue` provides a publisher that emits a new value whenever it is set.
@propertyWrapper public struct Validated<Value> {
  private var value: Value
  
  public let validator: (Value) -> Bool
  
  private let subject = PassthroughSubject<Value, Never>()

  public init(wrappedValue: Value, _ validator: @escaping (Value) -> Bool) {
    assert(validator(wrappedValue))
    value = wrappedValue
    self.validator = validator
  }

  public var wrappedValue: Value {
    get {
      value
    }
    set {
      if validator(newValue) {
        value = newValue
      }
      subject.send(value)
    }
  }
  
  public var projectedValue: AnyPublisher<Value, Never> {
    subject.eraseToAnyPublisher()
  }
}
