# Tigo
Small &amp; simple reactive library

## Observables
Tigo has 2 kind of observables:

`Signal`: Value over time, "Hot" observable, typically properties and UI bindings.

`Promises`: Future value fired once, "Cold" observable, typically network call.

## Examples
### Basic Signal
```swift
let number = Signal<Int>()

number.onNext { value in
  print(value)
}

number.send(5) // print(5)
```
### Basic Observer
```swift
let number = Signal<Int>()

let observer = Observer<Int> { number in
  print(number)
}

number.bind(to: observer)
number.send(10) // print(10)
```
### Infix Operator
```swift
// These are equivalent

number.bind(to: observer)

observer <- number
```
### Standard list operations
```swift
let dog = Signal<Dog>()

let someObserver = Observer<String> { value in
  print(value)
}

someObserver <- dog
  .filter{ $0.isCute }
  .map{ "\($0.name) is a cute dog" }

let tigo = Dog(name: "Tigo", isCute: true)
let ruffus = Dog(name: "Ruffus", isCute: false)

dog.send(ruffus)
dog.send(tigo) // print("Tigo is a cute dog")
```
### UIBindings
```swift
let name = Signal<String>()
let label = UILabel()

label.tigo.text <- name

name.send("Tigo") // label.text is now "Tigo"
```
### Composition
You can also bind signals together easily!
```swift
let user = Signal<User>()
let username = Signal<String>()

username <- user.map { $0.name }

let karl = User(name: "Karl")

user.send(karl) // the username signal will receive "Karl"
```

## ToDo List
1. `Promise` type for "cold" observable
2. `KVO signal`
3. Use `Quick/Nimble` for testing
4. Carthage
5. Cocoapods
