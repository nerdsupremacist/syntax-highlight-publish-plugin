
import Foundation
import Publish
import Splash
import Ink

extension Plugin {
    public static func syntaxHighlighting(_ grammars: Grammar..., allowHighlightingSectionsWithExplanations: Bool = false) -> Self {
        return .syntaxHighlighting(grammars, allowHighlightingSectionsWithExplanations: allowHighlightingSectionsWithExplanations)
    }

    public static func syntaxHighlighting(_ grammars: [Grammar] = [.swift], allowHighlightingSectionsWithExplanations: Bool = false) -> Self {
        return Plugin(name: "Syntax Highlighting") { context in
            context.markdownParser.addModifier(
                .highlightCodeBlocks(grammars: grammars,
                                     allowHighlightingSectionsWithExplanations: allowHighlightingSectionsWithExplanations)
            )
        }
    }
}

extension Modifier {

    static func highlightCodeBlocks(grammars: [Grammar], allowHighlightingSectionsWithExplanations: Bool = false) -> Self {
        let grammars = Dictionary(grammars.map { ($0.name.lowercased(), $0.highlighter) }) { $1 }

        return Modifier(target: .codeBlocks) { html, markdown in
            var markdown = markdown.dropFirst("```".count)

            guard !markdown.hasPrefix("no-highlight") else {
                return html
            }

            let language = markdown.components(separatedBy: .whitespacesAndNewlines).first
            guard let highlighter = language.flatMap({ grammars[$0.lowercased()] }) else { return html }

            markdown = markdown
                .drop(while: { !$0.isNewline })
                .dropFirst()
                .dropLast("\n```".count)

            let delimiters = allowHighlightingSectionsWithExplanations ? String(markdown).delimiters() : []
            let code = allowHighlightingSectionsWithExplanations ? String(markdown).removingDelimiters() : String(markdown)

            do {
                var highlighted = try highlighter.html(code)
                var offset = 0
                for delimiter in delimiters {
                    highlighted.highlight(delimiter: delimiter - offset)
                    offset += delimiter.length
                }

                return "<pre><code>" + highlighted + "\n</code></pre>"
            } catch {
                return html
            }
        }
    }
}


fileprivate struct HighlightDelimiter {
    enum Kind {
        case start(explanation: String?)
        case end
    }

    let kind: Kind
    let offset: Int
    let length: Int

    static func + (lhs: HighlightDelimiter, rhs: Int) -> HighlightDelimiter {
        return HighlightDelimiter(kind: lhs.kind, offset: lhs.offset + rhs, length: lhs.length)
    }

    static func - (lhs: HighlightDelimiter, rhs: Int) -> HighlightDelimiter {
        return HighlightDelimiter(kind: lhs.kind, offset: lhs.offset - rhs, length: lhs.length)
    }
}

extension String {

    fileprivate mutating func highlight(delimiter: HighlightDelimiter) {
        let index = indexOffsetByTags(after: delimiter.offset)
        switch delimiter.kind {
        case .start(.some(let explanation)):
            insert(contentsOf: "<span class=\"highlighted\"><span class=\"explanation\">\(explanation)</span>", at: index)
        case .start(.none):
            insert(contentsOf: "<span class=\"highlighted\">", at: index)
        case .end:
            insert(contentsOf: "</span>", at: index)
        }
    }

    private func firstIndex(of character: Character, in range: ClosedRange<String.Index>) -> String.Index? {
        guard let index = self[range].firstIndex(of: character) else { return nil }
        return index.samePosition(in: self)!
    }

    private func firstIndex(of character: Character, in range: Range<String.Index>) -> String.Index? {
        guard let index = self[range].firstIndex(of: character) else { return nil }
        return index.samePosition(in: self)!
    }

    private func indexOffsetByTags(after offset: Int) -> String.Index {
        var index = startIndex
        var counter = 0

        var currentRangeOfTags: ClosedRange<String.Index>?

        while counter < offset {
            let lookUpUntil = self.index(index, offsetBy: offset - counter)
            if let startOfTag = firstIndex(of: "<", in: index...lookUpUntil) {
                guard let endOfTag = firstIndex(of: ">", in: startOfTag..<endIndex) else { fatalError("Malformed HTML") }

                if let current = currentRangeOfTags {
                    if index == startOfTag {
                        // Consecutive tags
                        currentRangeOfTags = current.lowerBound...endOfTag
                    } else {
                        currentRangeOfTags = startOfTag...endOfTag
                    }
                } else {
                    currentRangeOfTags = startOfTag...endOfTag
                }

                let difference = escapedCharacters(in: index...startOfTag).reduce(0) { $0 + $1.count - 1 }
                counter += distance(from: index, to: startOfTag) - difference
                index = self.index(after: endOfTag)
            } else if let firstEscapedCharacter = firstEscapedCharacter(in: index...lookUpUntil) {
                counter += distance(from: index, to: firstEscapedCharacter.lowerBound) + 1
                index = firstEscapedCharacter.upperBound
            } else {
                index = lookUpUntil
                counter = offset
            }
        }

        if let range = currentRangeOfTags, self.index(after: range.upperBound) == index {
            return range.lowerBound
        }

        return index
    }

}

extension String {
    private static let escapedCharacterPattern = "&(?:\\w+|#[0-9a-fA-F]+);"
    private static let escapedCharacters = try! NSRegularExpression(pattern: escapedCharacterPattern)

    fileprivate func firstEscapedCharacter(in range: ClosedRange<String.Index>) -> Range<String.Index>? {
        let nsRange = NSRange(range.lowerBound..., in: self)
        guard let match = String.escapedCharacters.firstMatch(in: self, options: [], range: nsRange),
              let matchRange = Range(match.range, in: self),
              range.contains(matchRange.lowerBound) else { return nil }

        return matchRange
    }

    private func escapedCharacters(in range: ClosedRange<String.Index>) -> [Substring] {
        let nsRange = NSRange(range, in: self)
        let matches = String.escapedCharacters.matches(in: self, options: [], range: nsRange)
        return matches.compactMap { match in
            guard let range = Range(match.range, in: self) else { return nil }
            return self[range]
        }
    }
}

extension String {
    private static let startPattern = "<\\$\\$(\\(([^)\\n]+)\\))?"
    private static let startExpression = try! NSRegularExpression(pattern: startPattern)
    private static let endDelimiter = "$$>"

    fileprivate func removingDelimiters() -> String {
        return replacingOccurrences(of: String.startPattern, with: "", options: .regularExpression)
            .replacingOccurrences(of: String.endDelimiter, with: "")
    }

    fileprivate func delimiters() -> [HighlightDelimiter] {
        return (startDelimiters() + endDelimiters()).sorted { $0.offset < $1.offset }
    }

    private func startDelimiters() -> [HighlightDelimiter] {
        let nsRange = NSRange(startIndex..<endIndex, in: self)
        return String.startExpression.matches(in: self, options: [], range: nsRange).map { match in
            let range = Range(match.range, in: self)!
            let explanationRange = Range(match.range(at: 2), in: self)
            let explanation = explanationRange.map { String(self[$0]) }
            let lengthDifference = explanation?.count ?? 0
            return HighlightDelimiter(kind: .start(explanation: explanation),
                                      offset: distance(from: startIndex, to: range.lowerBound),
                                      length: match.range.length - lengthDifference)
        }
    }

    private func endDelimiters() -> [HighlightDelimiter] {
        return ranges(of: String.endDelimiter).map { HighlightDelimiter(kind: .end, offset: distance(from: startIndex, to: $0.lowerBound), length: 3) }
    }

    private func ranges(of substring: String, options: CompareOptions = [], locale: Locale? = nil) -> [Range<Index>] {
        var ranges: [Range<Index>] = []
        while ranges.last.map({ $0.upperBound < self.endIndex }) ?? true,
            let range = self.range(of: substring, options: options, range: (ranges.last?.upperBound ?? self.startIndex)..<self.endIndex, locale: locale)
        {
            ranges.append(range)
        }
        return ranges
    }
}
