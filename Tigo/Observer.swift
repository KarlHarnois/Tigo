import Foundation

public struct Observer<T> {
  private let callback: (T) -> Void

  public init(_ callback: @escaping (T) -> Void) {
    self.callback = callback
  }

  public func send(_ value: T) {
    callback(value)
  }
}
