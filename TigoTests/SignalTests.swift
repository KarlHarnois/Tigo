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

  func test_map_with_initial_value() {
    let signal = Signal(10)
    var received: [Int] = []

    signal
      .map { $0 * 2 }
      .onNext { received.append($0) }

    signal.send(20)
    signal.send(30)

    XCTAssertEqual(received, [20, 40, 60])
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

  // MARK: - combined Operator Tests

  func test_combined_when_we_only_send_values_to_called_signal() {
    let a = Signal(5)
    let b = Signal("tigo")

    var received: [(Int, String)] = []

    a.combined(with: b).onNext { received.append($0) }

    a.send(10)
    a.send(20)

    let numbers = received.map { $0.0 }
    let strings = received.map { $0.1 }

    XCTAssertEqual(numbers, [5, 10, 20])
    XCTAssertEqual(strings, ["tigo", "tigo", "tigo"])
  }

  func test_combined_when_only_send_value_to_argument_signal() {
    let a = Signal("foo")
    let b = Signal(1)

    var received: [(String, Int)] = []

    a.combined(with: b).onNext { received.append($0) }

    b.send(3)
    b.send(6)
    b.send(9)
    b.send(12)

    let firstSeq = received.map { $0.0 }
    let secondSeq = received.map { $0.1 }

    XCTAssertEqual(firstSeq, ["foo", "foo", "foo", "foo", "foo"])
    XCTAssertEqual(secondSeq, [1, 3, 6, 9, 12])
  }

  func test_combined_when_both_signal_sends_value() {
    let a = Signal(11.0)
    let b = Signal("tigo")

    var received: [(Double, String)] = []

    a.combined(with: b).onNext { received.append($0) }

    a.send(0)
    b.send("foo")
    a.send(10)
    b.send("blob")

    let firstSeq = received.map { $0.0 }
    let secondSeq = received.map { $0.1 }

    XCTAssertEqual(firstSeq, [11, 0, 0, 10, 10])
    XCTAssertEqual(secondSeq, ["tigo", "tigo", "foo", "foo", "blob"])
  }

  func test_combined_with_other_operators() {
    let a = Signal(1)
    let b = Signal("a")

    var received: [String] = []

    a.combined(with: b)
      .map { String($0) + $1 }
      .filter { $0 != "2b" }
      .onNext { received.append($0) }

    a.send(2)
    b.send("b")
    a.send(3)

    XCTAssertEqual(received, ["1a", "2a", "3b"])
  }

  func test_multiple_combined() {
    let a = Signal(0)
    let b = Signal("foo")
    let c = Signal(100)

    var received: [String] = []

    a.combined(with: b).combined(with: c)
      .map { "\($0.0) \($0.1) \($1)" }
      .onNext { received.append($0) }

    a.send(1)
    b.send("dog")
    c.send(1000)

    XCTAssertEqual(received, ["0 foo 100", "1 foo 100", "1 dog 100", "1 dog 1000"])
  }

  func test_combined_when_a_signal_has_no_value() {
    let a = Signal<Int>()
    let b = Signal("foo")

    var received: [String] = []

    a.combined(with: b).map { "\($0) \($1)" }.onNext { received.append($0) }

    b.send("bar")
    b.send("baz")
    b.send("Tigo")

    XCTAssertEqual(received, [])
  }

  func test_combined_when_no_value_signal_starts_emitting() {
    let a = Signal<Int>()
    let b = Signal("foo")

    var received: [String] = []

    a.combined(with: b).map { String($0) + $1 }.onNext { received.append($0) }

    b.send("tigo")
    b.send("dog")
    a.send(1)

    XCTAssertEqual(received, ["1dog"])
  }

  // MARK: - Other Desired Behaviors Tests

  func test_assignment_created_in_a_temporary_scope_persist() {
    var received: [Int] = []
    let number = Signal(10)

    _ = {
      let doubled = number.map { $0 * 2 }

      doubled.onNext { received.append($0) }
    }()

    number.send(20)
    number.send(30)

    XCTAssertEqual(received, [20, 40, 60])
  }
}
