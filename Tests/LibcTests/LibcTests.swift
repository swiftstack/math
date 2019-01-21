import Test
@testable import libc

final class LibcTests: TestCase {
    func testLog2() {
        #if !arch(x86_64)
        assertEqual(log2(42.0), 5.3923174227787607)
        #endif
    }

    func testScalbn() {
        assertEqual(scalbn(0.7937005259840998, -1), 0.3968502629920499)
    }

    func testExp2() {
        assertEqual(exp2(3.0), 8.0)
        assertEqual(exp2(42.0), 4398046511104.0)
        assertEqual(exp2(-1.3333333333333333), 0.3968502629920499)
    }
}
