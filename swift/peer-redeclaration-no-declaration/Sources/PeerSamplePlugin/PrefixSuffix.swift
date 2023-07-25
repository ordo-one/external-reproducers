import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

func identifier(_ syntax: SyntaxProtocol) -> String {
    guard let identified = syntax.asProtocol(NamedDeclSyntax.self) else { // or IdentifiedDeclSyntax in older versions
        fatalError("Declaration is not identifyiable")
    }
    return identified.name.text // or `syntax.identifier.text` in older versions
}

public struct PublicPrefixMacro: PeerMacro {
    public static func expansion<
        Context: MacroExpansionContext,
        Declaration: DeclSyntaxProtocol
    >(
        of node: AttributeSyntax,
        providingPeersOf declaration: Declaration,
        in context: Context
    ) throws -> [DeclSyntax] {
        guard let typealiasDecl = declaration.as(TypealiasDeclSyntax.self) else {
            fatalError("Not a typealias")
        }
        
        let publicTypeAlias: DeclSyntax =
        """
        public typealias Prefix\(raw: identifier(typealiasDecl)) = \(raw: typealiasDecl.initializer.value)
        """
        return [publicTypeAlias]
    }
}

public struct SuffixMacro: PeerMacro {
    public static func expansion<
        Context: MacroExpansionContext,
        Declaration: DeclSyntaxProtocol
    >(
        of node: AttributeSyntax,
        providingPeersOf declaration: Declaration,
        in context: Context
    ) throws -> [DeclSyntax] {
        let name = identifier(declaration)
        
        let alias: DeclSyntax =
        """
        @Prefixed
        public typealias \(raw: name)Suffix = \(raw: name)
        """
        
        return [alias]
    }
}
