// A purely public class.
// If `internal import SharedLib` worked as a visibility boundary, a dylib
// that imports SharedLib internally should NOT re-export the symbols for
// this class. In practice both dylibs end up emitting it.
public final class PublicThing {
    public var value: Int = 0
    public init() {}
}
