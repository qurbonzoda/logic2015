//
// Created by Abdukodiri Kurbonzoda on 06/08/16.
//

import Foundation

typealias Assumptions = [LogicalExpression]
typealias Proof = [LogicalExpression]
typealias Header = (Assumptions, LogicalExpression)
typealias File = (Header, Proof)

public class Parser {
    static func parseFile(_ path: String) throws -> File {
        let content = try String(contentsOfFile: path, encoding: .utf8)
        var fileLines = [String]()
        content.enumerateLines { (line: String, flag: inout Bool) in fileLines.append(line) }
        return (parseHeader(fileLines[0]), fileLines.dropFirst().map { parseLogicalExpression($0)! })
    }
    
    static func parseHeader(_ header: String) -> Header {
        var sentences = header.replacingOccurrences(of: " ", with: "").components(separatedBy: ",")
        return (sentences.dropLast().map { parseLogicalExpression($0)! }, parseLogicalExpression(sentences[sentences.endIndex])!)
    }

    static func parseProof(_ proof: String) -> Proof {
        var proofLines = [String]()
        proof.enumerateLines { (line: String, flag: inout Bool) in proofLines.append(line) }
        return proofLines.map { parseLogicalExpression($0)! }
    }
    
    static func parseLogicalExpression(_ expression: String) -> LogicalExpression? {
        return LogicalExpressionParser(expression: expression).parseImplication();
    }

    private class LogicalExpressionParser {
        var expression: String
        var index: String.Index

        init(expression: String) {
            self.expression = expression.replacingOccurrences(of: " ", with: "")
            index = self.expression.startIndex
        }

        func parseImplication() -> LogicalExpression? {
            var result = parseConjunction()
            while expression[index] == "-" {
                advanceIndex()
                advanceIndex()
                result = .implication(result!, parseImplication()!)
            }
            return result
        }

        func parseDisjunction() -> LogicalExpression? {
            var result = parseConjunction()
            while expression[index] == "|" {
                advanceIndex()
                result = .disjunction(result!, parseConjunction()!)
            }
            return result
        }

        func parseConjunction() -> LogicalExpression? {
            var result = parseNegation()
            while expression[index] == "&" {
                advanceIndex()
                result = .conjunction(result!, parseNegation()!)
            }
            return result
        }

        func parseNegation() -> LogicalExpression? {
            var result = parseVariable()
            if (expression[index] == "(") {
                advanceIndex()
                result = parseImplication()
                advanceIndex()
            } else if expression[index] == "!" {
                advanceIndex()
                result = .negation(parseNegation()!)
            }
            return result
        }

        func parseVariable() -> LogicalExpression? {
            let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
            let digits = "0123456789"
            
            if letters.contains(expression[index]) {
                var name = ""
                while index != expression.endIndex && (letters.contains(expression[index]) || digits.contains(expression[index])) {
                    name.append(expression[index])
                    advanceIndex()
                }
                return .variable(name)
            }
            return nil
        }

        func advanceIndex() {
            index = expression.index(after: index)
        }
    }
}
