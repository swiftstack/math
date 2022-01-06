import Test
@testable import Math

final class MathTests: TestCase {
    func testLog2() {
        expect(log2(42.0) == 5.3923174227787607)
    }
}
