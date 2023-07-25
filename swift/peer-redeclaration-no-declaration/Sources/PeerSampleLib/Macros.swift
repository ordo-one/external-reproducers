import Foundation

@attached(peer, names: prefixed(Prefix))
public macro Prefixed() =
    #externalMacro(module: "PeerSamplePlugin", type: "PublicPrefixMacro")

@attached(peer, names: suffixed(Suffix))
public macro Suffixed() =
    #externalMacro(module: "PeerSamplePlugin", type: "SuffixMacro")
