import Tigo
import XCTest

final class SignalTests: XCTestCase {
  var signal: Signal<Int>!

  override func setUp() {
    signal = Signal<Int>()
  }

  // MARK: - Binding Tests

  func test_bind_to_observer() {
    var received: [Int] = []

    let observer = Observer<Int> { value in
      received.append(value)
    }

    signal.bind(to: observer)

    signal.send(1)
    signal.send(2)
    signal.send(3)

    XCTAssertEqual(received, [1, 2, 3])
  }

  func test_bind_to_signal() {
    var received: [Int] = []

    let other = Signal<Int>()
    other.onNext { received.append($0) }

    signal.bind(to: other)

    signal.send(50)
    signal.send(100)
    signal.send(150)

    XCTAssertEqual(received, [50, 100, 150])
  }

  func test_more_than_one_observers() {
    var receivedByA: [Int] = []
    var receivedByB: [Int] = []
    var receivedByC: [Int] = []

    let a = Observer<Int> { receivedByA.append($0) }
    let b = Observer<Int> { receivedByB.append($0) }
    let c = Observer<Int> { receivedByC.append($0) }

    signal.bind(to: a)
    signal.bind(to: b)
    signal.bind(to: c)

    signal.send(10)
    signal.send(100)
    signal.send(1000)

    XCTAssertEqual(receivedByA, [10, 100, 1000])
    XCTAssertEqual(receivedByB, [10, 100, 1000])
    XCTAssertEqual(receivedByC, [10, 100, 1000])
  }

  func test_onNext_sends_data() {
    var received: [Int] = []

    signal.onNext { received.append($0) }

    signal.send(9)
    signal.send(10)
    signal.send(11)

    XCTAssertEqual(received, [9, 10, 11])
  }

  func test_signal_pass_last_value_when_bound_to_observer() {
    var received: Int?
    let signal = Signal(10)
    let ob = Observer<Int> { received = $0 }

    ob <- signal

    XCTAssertEqual(received, 10)
  }

  func test_signal_pass_last_value_when_bound_to_signal() {
    var received: String?
    let a = Signal("tigo")
    let b = Signal<String>()

    b.onNext { received = $0 }
    a.bind(to: b)

    XCTAssertEqual(received, "tigo")
  }

  func test_signal_pass_last_value_when_calling_onNext() {
    var received: Bool?
    let signal = Signal(false)

    signal.onNext { received = $0 }

    XCTAssertEqual(received, false)
  }

  // MARK: - map Operator Tests

  func test_map() {
    var received: [String] = []

    signal.map(String.init).onNext { received.append($0) }

    signal.send(4)
    signal.send(5)
    signal.send(6)

    XCTAssertEqual(received, ["4", "5", "6"])
  }

  func test_multiple_maps() {
    var received: [String] = []

    signal
      .map { $0 * 2 }
      .map { $0 + 1 }
      .map(String.init)
      .map { $0 + " foo" }
      .onNext { received.append($0) }

    signal.send(10)
    signal.send(11)
    signal.send(12)

    XCTAssertEqual(received, ["21 foo", "23 foo", "25 foo"])
  }

  func test_map_with_multiple_observers() {
    var receivedByA: [String] = []
    var receivedByB: [Int] = []

    let a = Observer<String> { receivedByA.append($0) }
    let b = Observer<Int> { receivedByB.append($0) }

    signal
      .map { $0 + 1 }
      .map(String.init)
      .bind(to: a)

    signal
      .map { $0 + 10 }
      .bind(to: b)

    signal.send(10)
    signal.send(20)
    signal.send(30)

    XCTAssertEqual(receivedByA, ["11", "21", "31"])
    XCTAssertEqual(receivedByB, [20, 30, 40])
  }

  // MARK: - filter Operator Tests

  func test_filter() {
    var received: [Int] = []

    signal
      .filter { $0 > 10 }
      .onNext { received.append($0) }

    signal.send(20)
    signal.send(5)
    signal.send(100)
    signal.send(2)

    XCTAssertEqual(received, [20, 100])
  }

  func test_multiple_filters() {
    var received: [Int] = []

    signal
      .filter { $0 > 5 }
      .filter { $0 < 10 }
      .onNext { received.append($0) }

    signal.send(0)
    signal.send(12)
    signal.send(6)
    signal.send(9)
    signal.send(100)

    XCTAssertEqual(received, [6, 9])
  }

  func test_maps_and_filters() {
    var received: [String] = []

    signal
      .map { $0 + 1 }
      .filter { $0 > 5 }
      .map(String.init)
      .filter { $0 != "10" }
      .map { "\($0) foo" }
      .onNext { received.append($0) }

    signal.send(3)
    signal.send(5)
    signal.send(7)
    signal.send(9)

    XCTAssertEqual(received, ["6 foo", "8 foo"])
  }

  func test_multiple_observers_maps_and_filters() {
    var receivedByA: [Int] = []
    var receivedByB: [String] = []

    let a = Observer<Int> { receivedByA.append($0) }
    let b = Observer<String> { receivedByB.append($0) }

    signal
      .map { $0 + 1 }
      .filter { ($0 % 2) == 0 }
      .map { $0 * 5 }
      .bind(to: a)

    signal
      .map(String.init)
      .filter { $0 != "6" }
      .map { $0 + "foo" }
      .bind(to: b)

    signal.send(5)
    signal.send(6)
    signal.send(7)

    XCTAssertEqual(receivedByA, [30, 40])
    XCTAssertEqual(receivedByB, ["5foo", "7foo"])
  }
}
