import Foundation

struct ConditionalWrapper<A>: Wrapper, AnyWrapper {
  var wrapped: Signal<A>?
  private let condition: (A) -> Bool

  init(condition: @escaping (A) -> Bool) {
    self.condition = condition
  }

  func send(_ value: A) {
    guard condition(value) else { return }

    wrapped?.send(value)
  }
}
