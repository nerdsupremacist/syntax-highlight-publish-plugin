import XCTest
@testable import SyntaxHighlightPublishPlugin

final class syntax_highlight_publish_pluginTests: XCTestCase {
    func testExample() {
        let text = """
        protocol BuilderConstants {
          static var padding: Int { get }
          static var height: Int { get }
        }

        enum StandardConstants: BuilderConstants {
          static let padding = 20
          static let height = 100
        }

        class Builder<Constants: BuilderConstants> {

          func element() -> Element {
            return Element(padding: Constants.padding, height: Constants.height)
          }

        }

        protocol BuilderProtocol {
          func element() -> Element
        }

        class AnyBuilder: BuilderProtocol {

          let _element: () -> Element

          init<Builder: Builder>(_ builder:  Builder) {
            _element = builder.element
          }

          func element() -> Element {
            return _element()
          }

        }

        let builder = AnyBuilder(Builder<StandardConstants>())
        """

        let highlighted = try! Grammar.swift.highlighter.html(text)
        print(highlighted)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
