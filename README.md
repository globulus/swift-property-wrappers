# Swift Property Wrappers

A Collection of useful Swift [property wrappers](https://www.google.com/search?q=swift+property+wrappers) to make coding easier.

* 14 wrappers included.
* Most wrappers are **fully unit tested**.
* Most wrappers can be observed via `Publisher`s exposed in their `projectedValue`s.
* PRs welcome.

## Contents

Here's the list of all the wrappers included in the package.

### Atomic

* Synchronizes property reads and writes using the provided `DispatchQueue`.
* `projectedValue` exposes the wrapper itself and allows for using its `mutate` method that change and set the value at the same time.

Sample use:

```swift
@Atomic var value: Int = 0

let read = value // synchonized
value = 5 // also synchronized
$value.mutate { value in value *= 2 } // synchronized mutation
```

### Clamped

* Ensures that the property's `Comparable` value is always in the bounds of the provided **range**. The range can be specified either with its minimum and maximum value, or by a `ClosedRange`:
  + If the value set is lesser than lower bound of the range, the actual value set is the lower bound itself.
  + If the value set is greater than upper bound of the range, the actual value set is the upper bound itself.
* The initially assigned value is automatically clamped as well.
* `projectedValue` provides a `Publisher` that emits the new value on set.

Sample use:

```swift
@Clamped(min: 10, max: 20) var minMax: Int = 10
@Clamped(5...10) var range: Int = 5

minMax = 25
minMax == 20 // clamped to upper bound
range = 1
range == 5 // clamped to lower bound
minMax = 19
minMax == 19 // the value was already within bounds
```

### ColorHex

* A string wrapper that exposes a SwiftUI `Color` via its `projectedValue` if the value represents a valid **hex color code**. Multiple color formats are supported based on [this solution](https://swiftuirecipes.com/blog/hex-color-in-swiftui).
* If the string value is not a valid hex color string, `projectedValue` is `nil`.

Sample use:

```swift
@ColorHex var colorHex = "fff"
  
$colorHex == Color(white: 1)

colorHex = "FF0000"
$colorHex == Color(red: 1, green: 0, blue: 0)

colorHex = "fail"
$colorHex == nil
```

### CopyOnWrite

* Allows for pass-by-copy by ensuring that `copy` method is invoked whenever a value is assigned.
* Property type must conform to the `Copyable` protocol.

Sample use:

```swift
class CopyableItem: Copyable {
  let name: String
  let price: Int
  
  init(name: String, price: Int) {
    self.name = name
    self.price = price
  }
  
  func copy() -> Self {
    CopyableItem(name: name, price: price) as! Self
  }
}

// ...

@CopyOnWrite var item: CopyableItem = CopyableItem(name: "a", price: 0)
  
let newItem = CopyableItem(name: "test", price: 1)
item = newItem
item !== newItem // not the same reference
item.name == newItem.name // same copied value
```

### Delayed

* Allows for late initialization of properties, thus working around Swift's init safety checks. This can avoid the need for implicitly-unwrapped optionals in multi-phase initialization.
* If the value is read before being written to for the first time, a `Never`-returning block is invoked.
  + This block can be set manually and defaults to `fatalError`.
* `projectedValue` returns `true` if the value is already set, so that you can check without triggering a potentially fatal `get.

Sample use:

```swift
@Delayed var value: String

$value == false // not set yet
let read = value // fatal error

value = ""
let read = value // works!
$value == true // was set
```

### Expirable

* Property wrapper for a value that "expires" after a set period of time - trying to read the value `expirationPeriod` seconds after it was last set will return `nil`.
* Useful for properties whose underlying data should periodically be refreshed without having to resort to scheduled notifications.

Sample use:

```swift
@Expirable(10) var value: Int? // expires 10 seconds after it is set

value == nil // not set yet
value = 10
value == 10 // works
// sleep for 5 seconds...
value == 10 // still there
// sleep for 5 more seconds
value == nil // expired and nulled
```

### LazyWithReset

* Allows for lazy evaluation of properties with the added option of resetting them, so that the lazy initialization block runs again. In other words, if you have a `lazy var` that should, for whatever reason, be re-evaluated on next get, use this property wrapper.
* `projectedValue` exposes the wrapper itself and allows for using its `reset` method.

Sample use:

```swift
@LazyWithReset({ Date().timeIntervalSince1970 }) var currentTime: TimeInterval

let time = currentTime
let time2 = currentTime
time == time2 // just one lazy evaluation occurred
$currentTime.reset() // re-evaluate on next get
let time3 = currentTime
time3 != time // new lazy evaluation occurred
```

### Localized

* Allows for direct mapping of localized keys to their string values without using `NSLocalizedString`.
* Simply assign the key to the property and you'll get the localized string out.
* `projectedValue` provides a publisher that emits a new value on set.

Sample use:

```swift
@Localized var emailTitle = "email-title-key"

// Providing that your Localized.strings contains "email-title-key" = "Email";
Text(emailTitle) // shows Email
```

### Logged

* Allows for custom blocks of code to be invoked whenever the property is read or written to. The intended use case for this is to log access to the property, but the generic nature of the callbacks makes this wrapper quite versatile.
* By default, read block is `nil` and write block prints the newly set value.
* `projectedValue` provides a publisher that emits a new value on set.

Sample use:

```swift
@Logged var myValue: Int = 10

myValue = 10 // prints 10 in the log

// custom actions on read and write
@Logged(read: { readLog += "Read: \($0)\n" },
        write: { writeLog += "Write: \($0)\n" }) var value: Int = 0
```

### Mocked

* Always returns the value specified by the `mock` block.
* The most common use case for this is to easily inject temporary mock functionality in a single place without having to modify code anywhere else.
* While assignments don't have effect on the returned value, they are still accessible via `projectedValue.

Sample use:

```swift
protocol ItemRepo {
  func fetch() -> [Item]
  func upsert(item: Item)
}

class RealRepo: ItemRepo {
  private var items = Set<Item>()
  
  func fetch() -> [Item] {
    Array(items)
  }
  
  func upsert(item: Item) {
    items.insert(item)
  }
}

class MockRepo: ItemRepo {
  static let shared = MockRepo()
  
  func fetch() -> [Item] {
    [Item(name: "test", price: 1)]
  }
  
  func upsert(item: Item) { }
}


@Mocked({ MockRepo.shared }) var repo: ItemRepo = RealRepo()

// always returns the mocked value
let fetched = repo.fetch()
fetched == [Item(name: "test", price: 1)]
repo.upsert(item: Item(name: "new", price: 2))
let fetchedAgain = repo.fetch()
fetchedAgain == fetched // no change as upsert in mock doesn't do anything
  
// projected value accesses real value
let fetched = $repo.fetch() // uses actual repo assigned
fetched == []
$repo.upsert(item: Item(name: "new", price: 2))
let fetchedAgain = $repo.fetch()
fetchedAgain == [Item(name: "new", price: 2)]
```

### Rounded

* Ensures that the floating-point value of this property is always rounded to the specified number of decimal places.
  + You can also specify the `FloatingPointRoundingRule`.
* `projectedValue` provides a publisher that emits a new value whenever it is set.

Sample use:

```swift
@Rounded(0) var zero: Float = 1.1
@Rounded(1) var one: Float = 1.15
@Rounded(2) var two: Float = 1.125
@Rounded(2, rule: .down) var twoDown: Float = 1.135

zero == 1
zero = 2.23
zero == 2
one == 1.2
two == 1.12
twoDown == 1.13
```

### Tranformed

* Transforms the assigned value using the provided block, allowing for a wide array of applications, from automatically formatting strings, transforming numbers, etc.
* `projectedValue` provides a publisher that emits a new value whenever it is set.

Sample use:

```swift
@Transformed({ -$0 }) var negated: Int = 0
@Transformed({ $0.trimmingCharacters(in: .whitespaces).lowercased() }) var formatted = ""
  
negated = 5
negated == -5

formatted = "  AbCDe  "
formatted == "abcde"
```

### UnitInterval

* Normalizes the assigned value to a value between 0 and 1 based on the provided range. E.g, color components are normally expressed as values between 0 and 255, while iOS requires them to be set as values between 0 and 1.
* `projectedValue` provides a publisher that emits a new value whenever it is set.

Sample use:

```swift
@UnitInterval(0...255) var red: CGFloat = 0

red == 0
red = 255
red == 1
red = 25.5
red == 0.1
```

### Validated

* Only sets the new value is it passes validation by the provided block, which allows for vetoing new values.
* `projectedValue` provides a publisher that emits a new value whenever it is set.

Sample use:

```swift
// only non-negative values, please
@Validated({ $0 >= 0 }) var value: Int = 0
  
value == 0
value = -1
value == 0 // -1 isn't a valid value so the old one is used
value = 1
value == 1 // 1 is a valid value so it overwrites the old one
```

## Installation

This component is distributed as a **Swift package**. Just add this URL to your package list:

```text
https://github.com/globulus/swift-property-wrappers
```

You can also use **CocoaPods**:

```ruby
pod 'SwiftPropertyWrappers', '~> 1.1.0'
```

## Changelog

* 1.1.1 - Added CocoaPods.
* 1.1.0 - Addded `LazyWithReset`.
* 1.0.0 - Initial release.


