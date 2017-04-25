import Foundation

protocol AnyWrapper {
  func send(_ value: Any)
}

protocol Wrapper {
  associatedtype A
  associatedtype B

  var wrapped: Signal<B>? { get set }
  func send(_ value: A)
}

extension Wrapper {
  func send(_ value: Any) {
    guard let value = value as? A else { return }

    send(value)
  }
}
