public typealias TransactionIdentifier = UInt64

public struct Timestamp {
    let _micro: UInt64
    
    public var micro: UInt64 {
        _micro
    }
    
    public init(_ micro: UInt64) {
        self._micro = micro
    }
}

public struct Markets {
    static var markets: [String] = []
    
    public static func setMarkets(_ markets: [String]) {
        Self.markets = markets
    }
    
    public static func hasMarket(_ mic: String) -> Bool {
        for market in Self.markets {
            if market == mic {
                return true
            }
        }
        return false
    }
}

public struct MIC: Equatable {
    @_spi(OrdoPrivate) public let value: UInt32
    
    public init(_ mic: String) {
        let value = mic.withCString { str in
            var value: UInt32 = 0
            for i in 0..<4 {
                value <<= 8
                value += UInt32(str[i])
            }
            return value
        }
        self.init(internal: value)
    }
    
    @_spi(OrdoPrivate) public init(internal mic: UInt32) {
        self.value = mic
    }
    
    public static let XEUR = MIC(internal: 1_000)
    public static let XSTO = MIC(internal: 2_000)
}
