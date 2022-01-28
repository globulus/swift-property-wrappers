import Foundation
import Combine

/// Allows for custom blocks of code to be invoked whenever the property is read or written to.
/// The default use case for this is to log access to the property, but it's actually more generic than that.
/// `projectedValue` provides a publisher that emits a new value whenever it is set.
@propertyWrapper public struct Logged<Value> {
  private var value: Value
  
  public let readLogger: ((Value) -> Void)?
  public let writeLogger: ((Value) -> Void)?
  
  private let subject = PassthroughSubject<Value, Never>()
  
  public init(wrappedValue: Value,
              read readLogger: ((Value) -> Void)? = nil,
              write writeLogger: ((Value) -> Void)? = { print($0) }) {
    value = wrappedValue
    self.readLogger = readLogger
    self.writeLogger = writeLogger
  }
  
  public var wrappedValue: Value {
    get {
      readLogger?(value)
      return value
    }
    set {
      value = newValue
      writeLogger?(value)
      subject.send(value)
    }
  }
  
  public var projectedValue: AnyPublisher<Value, Never> {
    subject.eraseToAnyPublisher()
  }
}
