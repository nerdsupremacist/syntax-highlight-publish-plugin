
import Foundation
import Syntax
import SyntaxTree
import SyntaxHighlight

extension Grammar {

    public init<Content : Parser>(_ parser: Content, name: String, allowWhitespaces: Bool = true, tokenType: @escaping (Kind?, [String : Any]) -> TokenType?) {
        self.init(ParserSyntaxTreeFactory(parser: parser, allowWhiteSpaces: allowWhitespaces), name: name, tokenType: tokenType)
    }


    public init<Content : Parser>(_ parser: Content, name: String, allowWhitespaces: Bool = true, tokenType: @escaping (Kind?) -> TokenType?) {
        self.init(ParserSyntaxTreeFactory(parser: parser, allowWhiteSpaces: allowWhitespaces), name: name, tokenType: tokenType)
    }

}

extension Grammar {

    public init<Content : Parser>(name: String, allowWhitespaces: Bool = true, @ParserBuilder parser: () -> Content) {
        self.init(ParserSyntaxTreeFactory(parser: parser(), allowWhiteSpaces: allowWhitespaces), name: name)
    }

}

private struct ParserSyntaxTreeFactory<Content : Parser>: SyntaxTreeFactory {
    let parser: Content
    let allowWhiteSpaces: Bool

    func parse(_ text: String) throws -> SyntaxTree {
        return try parser.syntaxTree(text, options: allowWhiteSpaces ? [.allowWhiteSpaces] : [])
    }
}
