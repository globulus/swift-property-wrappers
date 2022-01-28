import Foundation
import Combine

/// Ensures that assigned value is always in the bounds of the provided range.
/// If the value set is lesser than lower bound of the range, it is set to the lower bound.
/// If the value set is greater than upper bound of the range, it is set to the upper bound.
/// `projectedValue` provides a publisher that emits a new value whenever it is set.
@propertyWrapper public struct Clamped<Value: Comparable> {
  private var value: Value
  
  public let min: Value
  public let max: Value
  
  private let subject = PassthroughSubject<Value, Never>()

  public init(wrappedValue: Value, min: Value, max: Value) {
    value = wrappedValue
    self.min = min
    self.max = max
    value = clamp(wrappedValue)
  }
  
  public init(wrappedValue: Value, _ range: ClosedRange<Value>) {
    value = wrappedValue
    min = range.lowerBound
    max = range.upperBound
    value = clamp(wrappedValue)
  }

  public var wrappedValue: Value {
    get {
      value
    }
    set {
      value = clamp(newValue)
      subject.send(value)
    }
  }
  
  public var projectedValue: AnyPublisher<Value, Never> {
    subject.eraseToAnyPublisher()
  }
  
  private func clamp(_ value: Value) -> Value {
    if value < min {
      return min
    } else if value > max {
      return max
    } else {
      return value
    }
  }
}
