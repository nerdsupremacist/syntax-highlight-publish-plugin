
import Foundation
import SyntaxTree
import SyntaxHighlight

extension Grammar {

    fileprivate init(name: String, factory: SyntaxTreeFactory, tokenType: @escaping (Kind?, [String : Any]) -> TokenType?) {
        self.init(name: name, highlighter: SyntaxTreeBasedHighlighter(factory: factory, tokenType: tokenType))
    }

}

extension Grammar {

    public init(_ factory: SyntaxTreeFactory,
                name: String,
                tokenType: @escaping (Kind?, [String : Any]) -> TokenType?) {

        self.init(name: name, factory: factory, tokenType: tokenType)
    }

    public init(_ factory: SyntaxTreeFactory,
                name: String,
                tokenType: @escaping (Kind?) -> TokenType?) {

        self.init(factory, name: name) { kind, _ in tokenType(kind) }
    }

}

extension Grammar {

    public init(_ factory: SyntaxTreeFactory,
                name: String) {

        self.init(name: name, factory: factory) { kind, _ in
            guard let kind = kind else { return nil }
            return estimate(kind)
        }
    }

}

private func estimate(_ kind: Kind) -> TokenType? {
    let parts = Set(kind.rawValue.components(separatedBy: .punctuationCharacters).filter { !$0.isEmpty }.map { $0.singular.lowercased() })
    return estimate(parts)
}

private struct Rule {
    let part: String
    let token: TokenType?
}

private struct RuleSet: ExpressibleByDictionaryLiteral {
    let rules: [Rule]

    init(dictionaryLiteral elements: (String, TokenType?)...) {
        self.rules = elements.map { Rule(part: $0, token: $1) }
    }
}

private let ruleSet: RuleSet = [
    "punctuation" : nil,
    "storage" : .keyword,
    "comment" : .comment,
    "string" : .string,
    "number" : .number,
    "constant" : .number,
    "operator" : .call,
    "keyword" : .keyword,
    "property" : .property,
    "variable" : .property,
    "type" : .type,
    "preprocessor" : .preprocessing,
    "call": .call,
]

private func estimate(_ parts: Set<String>) -> TokenType? {
    for rule in ruleSet.rules {
        if parts.contains(rule.part) {
            return rule.token
        }
    }

    return nil
}
