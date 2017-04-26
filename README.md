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

someObserver <- dog.filter{ $0.isCute }.map{ $0 + " is a cute dog" }

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

## ToDo List
1. `Promise` type for "cold" observable
2. `KVO signal`
