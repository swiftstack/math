/*
 * Initial port of scalbn
 *
 * musl (musl/src/math/scalbn.c)
 */

func scalbn(_ x: Double, _ n: Int32) -> Double {
    var x = x
    var n = n
	if (n > 1023) {
		x *= 0x1p1023
		n -= 1023
		if (n > 1023) {
			x *= 0x1p1023
			n -= 1023
			if (n > 1023) {
                n = 1023
            }
		}
	} else if (n < -1022) {
		/* make sure final n < -53 to avoid double
		   rounding in the subnormal range */
		x *= 0x1p-1022 * 0x1p53
		n += 1022 - 53
		if (n < -1022) {
			x *= 0x1p-1022 * 0x1p53
			n += 1022 - 53
			if (n < -1022) {
				n = -1022
            }
		}
	}
	return x * Double(bitPattern: UInt64(0x3ff + n) << 52)
}
