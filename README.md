# Syntax Highlight Publish Plugin

Plugin to add syntax highlighting (for multiple languages) to your Publish Site, with the least amount of effort. 
It currently supports defining Grammars with:
- Syntax: A SwiftUI like DSL
- TextMate Grammars
- Splash Grammars

## Installation
### Swift Package Manager

You can install SyntaxHighlightPublishPlugin via [Swift Package Manager](https://swift.org/package-manager/) by adding the following line to your `Package.swift`:

```swift
import PackageDescription

let package = Package(
    [...]
    dependencies: [
        .package(url: "https://github.com/nerdsupremacist/syntax-highlight-publish-plugin.git", from: "0.1.0")
    ]
)
```

## Usage

You have three options to add new Grammars to your site:
- Use Syntax
- Use TextMate
- Use Splash

You are allowed to add as many grammars as you like. And the plugin will choose the correct grammar depending on the language in each code block:

```swift
try MyPublishSite().publish(using: [
    ...
    // use plugin and include all the grammars that you want to use (note: we only ship this plugin with Swift)
    .installPlugin(.syntaxHighlighting(.swift, .kotlin, .scala, .java, .json, .graphql)),
])
```

### Syntax

Syntax is a SwiftUI like parser builder DSL that you can use to define your custom Grammar structurally.
For example this is how you would write a Parser that can parse the output of FizzBuzz:

```swift
enum FizzBuzzValue {
    case number(Int)
    case fizz
    case buzz
    case fizzBuzz
}

struct FizzBuzzParser: Parser {
    var body: AnyParser<[FizzBuzzValue]> {
        Repeat {
            Either {
                IntLiteral().map { FizzBuzzValue.number($0) }

                Word("FizzBuzz").map(to: FizzBuzzValue.fizzBuzz)
                Word("Fizz").map(to: FizzBuzzValue.fizz)
                Word("Buzz").map(to: FizzBuzzValue.buzz)
            }
        }
    }
}
```

And in order to add it to our site we use the Parser to create a `Grammar`:

```swift
import SyntaxHighlightPublishPlugin

extension Grammar {
    // define Fizz Buzz Grammar
    static let fizzBuzz = Grammar(name: "FizzBuzz") {
        FizzBuzzParser()
    }
}

try MyPublishSite().publish(using: [
    ...
    // use plugin and include your Grammar
    .installPlugin(.syntaxHighlighting(.fizzbuzz)),
])
```

### TextMate

Most programming languages have a TextMate definition out there so that you don't have to put in the work in coding it all down. 

You can simply search for the VS Code plugin for your language of choice and in the repo you will most likely find a .tmLanguage file. 
That's all you need to add support for that language on your site.

Let's say for that you want to add support for Kotlin:

```
import SyntaxHighlightPublishPlugin

extension Grammar {
    static let kotlin = try! Grammar(textMateFile: URL(fileURLWithPath: "/path/to/Kotlin.tmLanguage"))
}

try MyPublishSite().publish(using: [
    ...
    .installPlugin(.syntaxHighlighting(.kotlin)),
])
```

### Splash

If you were already using Splash on your site before and put in the work to add a custom Splash Grammar. No problem. We can use that too:

```swift
import SyntaxHighlightPublishPlugin

extension Grammar {
    static let myLanguage = Grammar(name: "MyLanguage", grammar: MyGrammar())
}

try MyPublishSite().publish(using: [
    ...
    .installPlugin(.syntaxHighlighting(.myLanguage)),
])
```

## Contributions
Contributions are welcome and encouraged!

## License
SyntaxHighlightPublishPlugin is available under the MIT license. See the LICENSE file for more info.
