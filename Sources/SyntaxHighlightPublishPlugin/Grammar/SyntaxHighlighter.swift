
import Foundation

protocol SyntaxHighlighter {
    func html(_ text: String) throws -> String
}
