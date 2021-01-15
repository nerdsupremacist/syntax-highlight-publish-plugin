
import Foundation
import SyntaxTree
import SyntaxHighlight

struct SyntaxTreeBasedHighlighter {
    let factory: SyntaxTreeFactory
    let tokenType: (Kind?, [String : Any]) -> TokenType?
}

extension SyntaxTreeBasedHighlighter: SyntaxHighlighter {

    func html(_ text: String) throws -> String {
        return try factory.html(text, type: tokenType)
    }

}
