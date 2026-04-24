internal import SharedLib

@_cdecl("pluginB_probe")
public func pluginB_probe() -> Int {
    let thing = PublicThing()
    thing.value = 2
    return thing.value
}
