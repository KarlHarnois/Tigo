import Foundation

protocol Observable: class {
  associatedtype Value

  var observers: [Observer<Value>] { get set }
  var children: [AnyWrapper] { get set }

  func bind(to observer: Observer<Value>)
  func onNext(_ callback: @escaping (Value) -> Void)
}

extension Observable {
  internal func updateObservers(_ value: Value) {
    observers.forEach { observer in
      observer.send(value)
    }
  }

  internal func updateChildren(_ value: Value) {
    children.forEach { child in
      child.send(value)
    }
  }
}
