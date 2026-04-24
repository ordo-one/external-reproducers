internal import SharedLib

@_cdecl("pluginA_probe")
public func pluginA_probe() -> Int {
    let thing = PublicThing()
    thing.value = 1
    return thing.value
}
