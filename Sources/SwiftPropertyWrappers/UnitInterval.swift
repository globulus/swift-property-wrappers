import Foundation
import Combine

/// Normalizes the assigned value to a value between 0 and 1 based on the provided range.
/// `projectedValue` provides a publisher that emits a new value whenever it is set.
@propertyWrapper public struct UnitInterval<Value: FloatingPoint> {
  private var value: Value
  
  public let min: Value
  public let range: Value
  
  private let subject = PassthroughSubject<Value, Never>()

  public init(wrappedValue: Value, min: Value, max: Value) {
    assert(wrappedValue >= min && wrappedValue <= max)
    value = wrappedValue
    self.min = min
    range = max - min
  }
  
  public init(wrappedValue: Value, _ range: ClosedRange<Value>) {
    assert(range.contains(wrappedValue))
    value = wrappedValue
    self.min = range.lowerBound
    self.range = range.upperBound - min
  }

  public var wrappedValue: Value {
    get {
      value
    }
    set {
      value = (newValue - min) / range
      subject.send(value)
    }
  }
  
  public var projectedValue: AnyPublisher<Value, Never> {
    subject.eraseToAnyPublisher()
  }
}
