import Foundation
import SwiftSyntax
import SwiftLang


enum ResultCode {
    case sucess
    case fail
}

class FuzzerResult {
    let testResults: [TestResult]
    init(_ testResults: [TestResult]) {
        self.testResults = testResults
    }
}

protocol TestResult {
    var code: ResultCode { get }
    var source: SourceFileSyntax { get }
}

class CompilerTestResult: TestResult {
    var code: ResultCode
    var source: SourceFileSyntax
    // another information like compiler's error messages...
    
    init(code: ResultCode, source: SourceFileSyntax) {
        self.code = code
        self.source = source
        // ...
    }
}

class SourcekitdTestResult: TestResult {
    var code: ResultCode
    var source: SourceFileSyntax
    // another information like sourcekitd messages...
    
    init(code: ResultCode, source: SourceFileSyntax) {
        self.code = code
        self.source = source
        // ...
    }
}

protocol TestEngine {
    func run(_ source: SourceFileSyntax) -> TestResult
}

class CompilerTestEngine: TestEngine {
    func run(_ source: SourceFileSyntax) -> TestResult {
        return CompilerTestResult(code: ResultCode.fail, source: source)
    }
}

class SourcekitdTestEngine: TestEngine {
    func run(_ source: SourceFileSyntax) -> TestResult {
        // let connection = SourceKitdService()
        // let request = SourceKitdRequest(uid: SourceKitdUID.request_CodeComplete)
        // ...
        return SourcekitdTestResult(code: ResultCode.fail, source: source)
    }
}
