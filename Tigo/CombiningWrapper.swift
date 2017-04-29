import Foundation

final class CombiningWrapper<A, B>: Wrapper, AnyWrapper {
  var wrapped: Signal<(A, B)>?

  private weak var parentA: Signal<A>?
  private weak var parentB: Signal<B>?

  init(_ a: Signal<A>, _ b: Signal<B>) {
    parentA = a
    parentB = b
  }

  func _send(_ value: B) {
    guard let otherValue = parentA?.last else { return }
    let combined = (otherValue, value)

    wrapped?.send(combined)
  }

  func send(_ value: A) {
    guard let otherValue = parentB?.last else { return }
    let combined = (value, otherValue)

    wrapped?.send(combined)
  }
}
