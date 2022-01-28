import Foundation

/// Ensures that all reads, writes and mutations of the wrapped value are performed atomically
/// by using a `DispatchQueue` as a lock.
@propertyWrapper public class Atomic<Value> {
  private var value: Value
  
  public let queue: DispatchQueue

  public init(wrappedValue: Value,
              _ queue: DispatchQueue = DispatchQueue(label: "atomic-\(UUID().uuidString)")) {
    self.value = wrappedValue
    self.queue = queue
  }
    
  public var wrappedValue: Value {
    get {
      queue.sync {
        value
      }
    }
    set {
      queue.sync {
        value = newValue
      }
    }
  }
  
  public var projectedValue: Atomic<Value> {
    return self
  }
  
  public func mutate(_ mutation: (inout Value) -> Void) {
    queue.sync {
      mutation(&value)
    }
  }
}
