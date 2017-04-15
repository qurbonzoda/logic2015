//
// Created by Abdukodiri Kurbonzoda on 06/08/16.
//

import Foundation

typealias Assumptions = [LogicalExpression]
typealias Proof = [LogicalExpression]
typealias Header = (Assumptions, LogicalExperssion)
typealias File = (Header, Proof)

class Parser {
    static func parseFile(path: String) throws -> File {
        let content = try String(contentsOfFile: path, encoding: NSUTF8StringEncoding)
        content
    }
    static func parseHeader(header: String) -> Header {

    }
    static func parseProof(proof: String) -> Proof {

    }
    static func parseLogicalExpression(expression: String) -> LogicalExpression {
        let parseImplication = { (index: Int) -> (LogicalExpression, Int) in
            var result = parseDisjunction(index)

        }
        let parseDisjunction = { (index: Int) -> (LogicalExpression, Int) in
            var result = parseConjunction(index)

        }
        let parseConjunction = { (index: Int) -> (LogicalExpression, Int) in
            var result = parseNegation(index)

        }
        let parseNegation = { (index: Int) -> (LogicalExpression, Int) in
            var result = parseVariable(index)

        }
        let parseVariable = { (index: Int) -> (LogicalExpression, Int) in
            let letters = NSCharacterSet.letterCharacterSet()
            let digits = NSCharacterSet.decimalDigitCharacterSet()

            if letters.longCharacterIsMember(uni.value) {
                expression[index]
            }
        }
    }
}
