
import Foundation
import Splash

public typealias SplashGrammar = Splash.Grammar

extension Grammar {

    public init(name: String, grammar: SplashGrammar) {
        self.init(name: name, highlighter: SplashSyntaxHighlighter(grammar: grammar))
    }

}

private struct SplashSyntaxHighlighter: SyntaxHighlighter {
    let grammar: SplashGrammar

    func html(_ text: String) throws -> String {
        return Splash.SyntaxHighlighter(format: HTMLOutputFormat(), grammar: grammar).highlight(text)
    }
}
