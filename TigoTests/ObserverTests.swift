import Tigo
import XCTest

final class ObserverTests: XCTestCase {
  func test_send_pass_value_to_callback() {
    var acc = 0

    let ob = Observer<Int> { acc += $0 }

    ob.send(1)
    ob.send(2)
    ob.send(3)

    XCTAssertEqual(acc, 6)
  }
}
