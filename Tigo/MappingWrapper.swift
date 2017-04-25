import Foundation

struct MappingWrapper<A, B>: Wrapper, AnyWrapper {
  var wrapped: Signal<B>?
  private let mapping: (A) -> B

  init(mapping: @escaping (A) -> B) {
    self.mapping = mapping
  }

  func send(_ value: A) {
    let new = mapping(value)

    wrapped?.send(new)
  }
}
