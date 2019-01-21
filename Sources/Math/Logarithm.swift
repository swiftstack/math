#if arch(x86_64)
import func X86_64.log2l

@inlinable
public func log2(_ value: Double) -> Double {
    return Double(log2l(Float80(value)))
}
#else
@_exported import func libc.log2
#endif
