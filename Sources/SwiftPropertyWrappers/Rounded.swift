import Foundation
import Combine

/// Ensures that the floating-point value of this property is always rounded to the specified number
/// of decimal places. You can also specify the `FloatingPointRoundingRule`.
/// `projectedValue` provides a publisher that emits a new value whenever it is set.
@propertyWrapper public struct Rounded<Value: FloatingPoint> {
  private var value: Value
  
  public let decimalPlaces: Int
  public let rule: FloatingPointRoundingRule
  private let multiplier: Value
  
  private let subject = PassthroughSubject<Value, Never>()

  public init(wrappedValue: Value,
              _ decimalPlaces: Int,
              rule: FloatingPointRoundingRule = .toNearestOrEven) {
    value = wrappedValue
    self.decimalPlaces = decimalPlaces
    self.rule = rule
    multiplier = Value(NSDecimalNumber(decimal: pow(10.0, decimalPlaces)).intValue)
    value = round(wrappedValue)
  }

  public var wrappedValue: Value {
    get {
      value
    }
    set {
      value = round(newValue)
      subject.send(value)
    }
  }
  
  public var projectedValue: AnyPublisher<Value, Never> {
    subject.eraseToAnyPublisher()
  }
  
  private func round(_ value: Value) -> Value {
    (value * multiplier).rounded(rule) / multiplier
  }
}
