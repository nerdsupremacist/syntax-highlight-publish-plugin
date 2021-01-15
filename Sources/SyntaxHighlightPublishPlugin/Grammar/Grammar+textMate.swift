
import Foundation
import Syntax
import TextMate

extension Grammar {

    public init(textMate language: Language) {
        self.init(language, name: language.name)
    }

    public init(textMate data: Data) throws {
        let decoder = PropertyListDecoder()
        let language = try decoder.decode(Language.self, from: data)
        self.init(textMate: language)
    }

    public init(textMate string: String) throws {
        let data = string.data(using: .utf8)!
        try self.init(textMate: data)
    }

    public init(textMateFile url: URL) throws {
        let data = try Data(contentsOf: url)
        try self.init(textMate: data)
    }

    public init(relativeTextMateFile path: String, currentFolder: String = #file) throws {
        let file = URL(fileURLWithPath: currentFolder).deletingLastPathComponent().appendingPathComponent(path)
        try self.init(textMateFile: file)
    }

}
