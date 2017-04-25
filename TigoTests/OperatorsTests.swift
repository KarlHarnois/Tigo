import Tigo
import XCTest

final class OperatorTests: XCTestCase {
  func test_bind_signal_to_observer() {
    let signal = Signal<Int>()

    var received: [Int] = []

    let ob = Observer<Int> { received.append($0) }

    ob <- signal

    signal.send(1)
    signal.send(2)
    signal.send(3)

    XCTAssertEqual(received, [1, 2, 3])
  }

  func test_bind_signal_to_signal() {
    let a = Signal<Int>()
    let b = Signal<Int>()

    var received: [Int] = []

    b.onNext { received.append($0) }

    b <- a

    a.send(4)
    a.send(5)
    a.send(6)

    XCTAssertEqual(received, [4, 5, 6])
  }
}
