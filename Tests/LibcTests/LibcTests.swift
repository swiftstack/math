import Test
@testable import libc

final class LibcTests: TestCase {
    func testLog2() {
        #if !arch(x86_64)
        expect(log2(42.0) == 5.3923174227787607)
        #endif
    }

    func testScalbn() {
        expect(scalbn(0.7937005259840998, -1) == 0.3968502629920499)
    }

    func testExp2() {
        expect(exp2(3.0) == 8.0)
        expect(exp2(42.0) == 4398046511104.0)
        expect(exp2(-1.3333333333333333) == 0.3968502629920499)
    }
}
