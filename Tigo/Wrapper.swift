import Foundation

protocol AnyWrapper {
  func send(_ value: Any)
}

protocol Wrapper {
  associatedtype Output
  associatedtype Input

  var wrapped: Signal<Output>? { get set }
  func send(_ value: Input)
}

extension Wrapper {
  func send(_ value: Any) {
    guard let value = value as? Input else { return }

    send(value)
  }
}
