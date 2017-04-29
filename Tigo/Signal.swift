import Foundation

public final class Signal<T>: Observable {
  internal var observers: [Observer<T>] = []
  internal var children: [AnyWrapper] = []

  // MARK: - Value

  var last: T? {
    return stream.last
  }

  private var stream: [T] = [] {
    didSet {
      guard let value = stream.last else { return }

      updateObservers(value)
      updateChildren(value)
    }
  }

  // MARK: - Init

  public init() {}

  public init(_ initialValue: T) {
    stream.append(initialValue)
  }

  // MARK: - Operators

  public func map<A>(_ f: @escaping (T) -> A) -> Signal<A> {
    let new = Signal<A>()

    var wrapper = MappingWrapper(mapping: f)
    wrapper.wrapped = new
    subscribe(wrapper)

    return new
  }

  public func filter(_ f: @escaping (T) -> Bool) -> Signal<T> {
    let new = Signal<T>()

    var wrapper = ConditionalWrapper(condition: f)
    wrapper.wrapped = new
    subscribe(wrapper)

    return new
  }

  public func combined<A>(with other: Signal<A>) -> Signal<(T, A)> {
    let new = Signal<(T, A)>()

    let wrapper = CombiningWrapper(self, other)
    wrapper.wrapped = new

    other.onNext { [weak wrapper] value in
      wrapper?._send(value)
    }

    subscribe(wrapper)

    return new
  }

  // MARK: - Bindings

  public func send(_ value: T) {
    stream.append(value)
  }

  /**
   Apply a pure function on the signal's last value then emit the result.
   */
  public func apply(_ f: (T) -> T) {
    guard let lastValue = last else { return }

    let newValue = f(lastValue)

    send(newValue)
  }

  /**
   The signal sends it's last received value to the observer instantly (if any). Then
   it sends new value every time it receives one.
   */
  public func bind(to observer: Observer<T>) {
    subscribe(observer)
  }

  /**
   The bound signal sends it's last received value instantly (if any) then every time
   it receives a new value.
   */
  public func bind(to signal: Signal<T>) {
    let ob = Observer<T> { [weak signal] value in
      signal?.send(value)
    }

    subscribe(ob)
  }

  /**
   The signal will call the callback with its last received value if any.
   Then the callback is called again with every new value sent to the signal.
   */
  public func onNext(_ callback: @escaping (T) -> Void) {
    let ob = Observer(callback)

    subscribe(ob)
  }

  // MARK: - Helpers

  /**
   Append the passed observer to the signal's contained observers then pass the
   last received value (if any) to the new observer.
   */
  private func subscribe(_ observer: Observer<T>) {
    observers.append(observer)

    if let value = last { observer.send(value) }
  }

  private func subscribe(_ wrapper: AnyWrapper) {
    children.append(wrapper)

    if let value = last { wrapper.send(value) }
  }
}
