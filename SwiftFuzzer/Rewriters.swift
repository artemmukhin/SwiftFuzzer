import Foundation
import SwiftSyntax
import SwiftLang

class Renamer: SyntaxRewriter {
    override func visit(_ node: FunctionDeclSyntax) -> DeclSyntax {
        if node.identifier.text == "foo" {
            return super.visit(node.withIdentifier(SyntaxFactory.makeIdentifier("bar")))
        } else {
            return super.visit(node)
        }
    }
}

class ReturnRewriter: SyntaxRewriter {
    let number: Int32
    
    init(number: Int32) {
        self.number = number
    }
    
    override func visit(_ node: FunctionDeclSyntax) -> DeclSyntax {
        let returnKeyword = SyntaxFactory.makeReturnKeyword(leadingTrivia: Trivia.spaces(0), trailingTrivia: Trivia.spaces(1))
        let integerToken = SyntaxFactory.makeIntegerLiteral(String(self.number), leadingTrivia: Trivia.spaces(1))
        let integerExpr = SyntaxFactory.makeIntegerLiteralExpr(digits: integerToken)
        let returnStmt = SyntaxFactory.makeReturnStmt(returnKeyword: returnKeyword, expression: integerExpr)
        let codeBlockItem = SyntaxFactory.makeCodeBlockItem(item: returnStmt, semicolon: nil)
        
        let codeBlock = SyntaxFactory.makeBlankCodeBlock()
            .withLeftBrace(SyntaxFactory.makeLeftBraceToken(leadingTrivia: Trivia.spaces(0), trailingTrivia: Trivia.newlines(1)))
            .withStatements(SyntaxFactory.makeCodeBlockItemList([codeBlockItem]))
            .withRightBrace(SyntaxFactory.makeRightBraceToken(leadingTrivia: Trivia.newlines(1), trailingTrivia: Trivia.newlines(1)))
        
        return super.visit(node.withBody(codeBlock))
    }
}


class MainRewriter: SyntaxRewriter {
    let topLevelRewriter = TopLevelRewriter()
    
    override func visit(_ node: SourceFileSyntax) -> Syntax {
        var codeBlockItems = [CodeBlockItemSyntax]()

        for (_, child) in node.statements.enumerated() {
            let item = child.item
            let codeBlockItem = SyntaxFactory.makeCodeBlockItem(item: topLevelRewriter.visit(child.item), semicolon: nil)
            codeBlockItems.append(codeBlockItem)
        }
        let itemList = SyntaxFactory.makeCodeBlockItemList(codeBlockItems)
        let eofToken = SyntaxFactory.makeToken(TokenKind.eof, presence: SourcePresence.present)
        return SyntaxFactory.makeSourceFile(statements: itemList, eofToken: eofToken)
    }
}

// top-level-declaration → statements­(opt)­
class TopLevelRewriter: SyntaxRewriter {
    // create all `Rewriter`s related to top-level statements
    let funcDeclRewriter = FuncDeclRewriter()
    let classDeclRewriter = ClassDeclRewriter()
    // ...
    
    // override all `visit`s related to top-level statements
    override func visit(_ node: FunctionDeclSyntax) -> DeclSyntax {
        let funcWithNewName = node.withIdentifier(SyntaxFactory.makeIdentifier("changedName"))
        return funcDeclRewriter.visit(funcWithNewName)
    }
    
    override func visit(_ node: ClassDeclSyntax) -> DeclSyntax {
        let classWithNewName = node.withIdentifier(SyntaxFactory.makeIdentifier("class1"))
        return classDeclRewriter.visit(classWithNewName)
    }
    // ...
}

// function-declaration → function-head ­function-name­ generic-parameter-clause(­opt)
//                        function-signature­ generic-where-clause­(opt) ­function-body(­opt)­
class FuncDeclRewriter: SyntaxRewriter {
    override func visit(_ node: DeclModifierSyntax) -> Syntax {
        // ...
        return super.visit(node)
    }
}

class ClassDeclRewriter: SyntaxRewriter {
    // ...
}

