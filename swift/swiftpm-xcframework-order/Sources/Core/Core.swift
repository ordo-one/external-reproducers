import Alpha
import Beta
import Gamma
import Delta
import Epsilon
import Zeta

/// Mirrors a module that depends on several binary xcframework targets.
public func coreValue() -> Int {
    alpha() + beta() + gamma() + delta() + epsilon() + zeta()
}
