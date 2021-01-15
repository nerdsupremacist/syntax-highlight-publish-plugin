import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(syntax_highlight_publish_pluginTests.allTests),
    ]
}
#endif
