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
