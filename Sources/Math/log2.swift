/*
 * Initial port of log2
 *
 * musl (src/math/log2.c)
 * FreeBSD (lib/msun/src/e_log2.c)
 */

let ivln2hi = 1.44269504072144627571e+00, /* 0x3ff71547, 0x65200000 */
    ivln2lo = 1.67517131648865118353e-10, /* 0x3de705fc, 0x2eefa200 */
    lg1 = 6.666666666666735130e-01,  /* 3FE55555 55555593 */
    lg2 = 3.999999999940941908e-01,  /* 3FD99999 9997FA04 */
    lg3 = 2.857142874366239149e-01,  /* 3FD24924 94229359 */
    lg4 = 2.222219843214978396e-01,  /* 3FCC71C5 1D8E78AF */
    lg5 = 1.818357216161805012e-01,  /* 3FC74664 96CB03DE */
    lg6 = 1.531383769920937332e-01,  /* 3FC39A09 D078C69F */
    lg7 = 1.479819860511658591e-01  /* 3FC2F112 DF3E5244 */

/*
 * Return the base 2 logarithm of x.  See log.swift for most comments.
 *
 * Reduce x to 2^k (1+f) and calculate r = log(1+f) - f + f*f/2
 * as in log.swift, then combine and scale in extra precision:
 *    log2(x) = (f - f*f/2 + r)/log(2) + k
 */

public func log2(_ x: Double) -> Double {
    var x = x

    var hx = x.highWord
    let lx = x.lowWord

    var k: Int32 = 0
    if hx < 0x00100000 || hx >> 31 != 0 {
        /* log(+-0)=-inf */
        guard x.bitPattern << 1 != 0 else { return -Double.infinity  }
        /* log(-#) = NaN */
    	guard hx >> 31 == 0 else { return Double.nan  }
    	/* subnormal number, scale x up */
    	k -= 54
    	x *= 0x1p54
    	hx = x.highWord
    } else if hx >= 0x7ff00000 {
    	return x
    } else if hx == 0x3ff00000 && lx == 0 {
    	return 0
    }

    /* reduce x into [sqrt(2)/2, sqrt(2)] */
    hx += 0x3ff00000 - 0x3fe6a09e
    k += Int32(hx >> 20) - 0x3ff
    hx = (hx & 0x000fffff) + 0x3fe6a09e
    x = Double(high: hx, low: lx)

    let f = x - 1.0
    let hfsq = 0.5 * f * f
    let s = f / (2.0 + f)
    let z = s * s
    var w = z * z
    let t1 = w * (lg2 + w * (lg4 + w * lg6))
    let t2 = z * (lg1 + w * (lg3 + w * (lg5 + w * lg7)))
    let r = t2 + t1

    /*
     * f-hfsq must (for args near 1) be evaluated in extra precision
     * to avoid a large cancellation when x is near sqrt(2) or 1/sqrt(2).
     * This is fairly efficient since f-hfsq only depends on f, so can
     * be evaluated in parallel with r.  Not combining hfsq with r also
     * keeps r small (though not as small as a true `lo' term would be),
     * so that extra precision is not needed for terms involving r.
     *
     * Compiler bugs involving extra precision used to break Dekker's
     * theorem for spitting f-hfsq as hi+lo, unless double_t was used
     * or the multi-precision calculations were avoided when double_t
     * has extra precision.  These problems are now automatically
     * avoided as a side effect of the optimization of combining the
     * Dekker splitting step with the clear-low-bits step.
     *
     * y must (for args near sqrt(2) and 1/sqrt(2)) be added in extra
     * precision to avoid a very large cancellation when x is very near
     * these values.  Unlike the above cancellations, this problem is
     * specific to base 2.  It is strange that adding +-1 is so much
     * harder than adding +-ln2 or +-log10_2.
     *
     * This uses Dekker's theorem to normalize y+val_hi, so the
     * compiler bugs are back in some configurations, sigh.  And I
     * don't want to used double_t to avoid them, since that gives a
     * pessimization and the support for avoiding the pessimization
     * is not yet available.
     *
     * The multi-precision calculations for the multiplications are
     * routine.
     */

    /* hi+lo = f - hfsq + s*(hfsq+r) ~ log(1+f) */
    var hi = f - hfsq
    hi.clearLowWord()
    let lo = f - hi - hfsq + s * (hfsq + r)

    var val_hi = hi * ivln2hi
    var val_lo = (lo + hi) * ivln2lo + lo * ivln2hi

    /* spadd(val_hi, val_lo, y) */
    let y = Double(k)
    w = y + val_hi
    val_lo += (y - w) + val_hi
    val_hi = w

    return val_lo + val_hi
}

extension Double {
    @inline(__always)
    init(high: UInt32, low: UInt32) {
        self.init(bitPattern: UInt64(high) << 32 | UInt64(low))
    }

    @inline(__always)
    mutating func clearLowWord() {
        self = Double(bitPattern: bitPattern & 0xffffffff_00000000)
    }

    var highWord: UInt32 {
        @inline(__always)
        get { return UInt32(truncatingIfNeeded: bitPattern >> 32) }
    }

    var lowWord: UInt32 {
        @inline(__always)
        get { return UInt32(truncatingIfNeeded: bitPattern) }
    }
}
