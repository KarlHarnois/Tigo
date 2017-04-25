import Foundation

public final class Signal<T>: Observable {
  internal var observers: [Observer<T>] = []
  internal var children: [AnyWrapper] = []

  private var stream: [T] = [] {
    didSet {
      guard let value = stream.last else { return }

      updateObservers(value)
      updateChildren(value)
    }
  }

  // MARK: - Init

  public init() {}

  // MARK: - Operators

  public func map<A>(_ f: @escaping (T) -> A) -> Signal<A> {
    let new = Signal<A>()

    var wrapper = MappingWrapper(mapping: f)
    wrapper.wrapped = new
    children.append(wrapper)

    return new
  }

  public func filter(_ f: @escaping (T) -> Bool) -> Signal<T> {
    let new = Signal<T>()

    var wrapper = ConditionalWrapper(condition: f)
    wrapper.wrapped = new
    children.append(wrapper)

    return new
  }

  // MARK: - Bindings

  public func send(_ value: T) {
    stream.append(value)
  }

  public func bind(to observer: Observer<T>) {
    observers.append(observer)
  }

  public func onNext(_ callback: @escaping (T) -> Void) {
    let ob = Observer(callback)

    observers.append(ob)
  }
}
