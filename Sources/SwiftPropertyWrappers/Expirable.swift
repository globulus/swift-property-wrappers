import Foundation

/// Property wrapper for a value that "expires" after a set period of time.
/// In effect, trying to read the value `expirationPeriod` seconds after it was set will return `nil`.
@propertyWrapper public struct Expirable<Value> {
    public let expirationPeriod: TimeInterval
  
    private var value: Value? = nil
    private var timestamp: TimeInterval = 0
    private var currentTime: TimeInterval {
        Date().timeIntervalSince1970
    }
    
    init(_ expirationPeriod: TimeInterval) {
        self.expirationPeriod = expirationPeriod
    }
    
    public var wrappedValue: Value? {
        mutating get {
            if value == nil {
                return nil
            } else if currentTime - timestamp > expirationPeriod {
                value = nil
                return nil
            } else {
                return value
            }
        }
        mutating set {
            value = newValue
            timestamp = currentTime
        }
    }
}
