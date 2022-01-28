import Foundation
import Combine

/// Calls the provided block whenever the value is set and stores its output in `wrappedValue`.
/// `projectedValue` provides a publisher that emits a new value whenever it is set.
@propertyWrapper public struct Transformed<Value> {
  private var value: Value
  
  public let transformer: (Value) -> Value
  
  private let subject = PassthroughSubject<Value, Never>()

  public init(wrappedValue: Value, _ transformer: @escaping (Value) -> Value) {
    value = transformer(wrappedValue)
    self.transformer = transformer
  }

  public var wrappedValue: Value {
    get {
      value
    }
    set {
      value = transformer(newValue)
      subject.send(value)
    }
  }
  
  public var projectedValue: AnyPublisher<Value, Never> {
    subject.eraseToAnyPublisher()
  }
}
