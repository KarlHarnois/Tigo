import Foundation

precedencegroup SignalPrecedenceGroup {
  associativity: left
  higherThan: AssignmentPrecedence
  lowerThan: LogicalDisjunctionPrecedence
}

// MARK: - Bind Operator

infix operator <- : SignalPrecedenceGroup

/// Binds signal to observer.
public func <- <T>(observer: Observer<T>, signal: Signal<T>) {
  signal.bind(to: observer)
}

/// Binds right to left signal.
public func <- <T>(lhs: Signal<T>, rhs: Signal<T>) {
  rhs.bind(to: lhs)
}
