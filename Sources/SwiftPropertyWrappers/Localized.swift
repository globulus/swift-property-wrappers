import Foundation
import Combine

/// Allows for direct mapping of localized keys to their string values without using `NSLocalizedString`.
/// Simply assign the key to the property and you'll get the localized string out.
/// `projectedValue` provides a publisher that emits a new value whenever it is set.
@propertyWrapper public struct Localized {
  private var value: String
  
  private let subject = PassthroughSubject<String, Never>()

  public init(wrappedValue: String) {
    value = wrappedValue
  }

  public var wrappedValue: String {
    get {
      value
    }
    set {
      value = NSLocalizedString(newValue, comment: "")
      subject.send(value)
    }
  }
  
  public var projectedValue: AnyPublisher<String, Never> {
    subject.eraseToAnyPublisher()
  }
}
