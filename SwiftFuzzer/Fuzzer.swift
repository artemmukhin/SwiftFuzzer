import Foundation
import SwiftSyntax
import SwiftLang


class Fuzzer {
    let sourceFilePath: String
    
    private let parsedSource: SourceFileSyntax
    private let mainRewriter = MainRewriter()
    private let testEngines: [TestEngine] = [CompilerTestEngine(), SourcekitdTestEngine()/*, ...*/]
    
    init?(sourceFilePath: String) {
        let currentFile = URL(fileURLWithPath: sourceFilePath)
        let currentFileContents = try? String(contentsOf: currentFile)
        let parsedSource = try? SourceFileSyntax.parse(currentFile)
        if (parsedSource == nil) { return nil }
        
        self.parsedSource = parsedSource!
        self.sourceFilePath = sourceFilePath
    }
    
    public func run() -> FuzzerResult {
        var results = [TestResult]()
        while (true) {
            let newSwiftCode = mainRewriter.visit(parsedSource) as? SourceFileSyntax
            if (newSwiftCode == nil) { /* handle this case */ continue }
            
            for testEngine in testEngines {
                let result = testEngine.run(newSwiftCode!)
                if (result.code == ResultCode.fail) {
                    print("Some message")
                    print(newSwiftCode!)
                    print()
                }
            }
        }
    }
}
