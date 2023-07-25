import PeerSampleLib

@Suffixed // + @Prefixed
public struct MyStruct {
}

// NB! 
// Add the following line to ensure that code was generated: 

public typealias PrefixMyStructSuffix = MyStructSuffix

let aa = MyStructSuffix()
let bb = PrefixMyStructSuffix()
