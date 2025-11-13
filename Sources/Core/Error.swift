public enum LoxError: Swift.Error {
  case scanner(ScannerError)
  case parser(ParserError)
  case interpreter(InterpreterError)
}

public typealias Result<T> = Swift.Result<T, LoxError>

extension LoxError: CustomStringConvertible {
  public var description: String {
    switch self {
    case .scanner(let e):
      switch e {
      case .unexpectedCharacter(let line):
        "[line \(line)] Error: Unexpected character."
      case .unterminatedString(let line):
        "[line \(line)] Error: Unterminated string."
      }
    case .parser(let e):
      switch e {
      case let .expectExpressionAnd(token, type):
        "[line \(token.line)] Error at \(isEndStr(token)): Expect '\(type.description)' after expression."
      case let .expectExpression(token):
        "[line \(token.line)] Error at \(isEndStr(token)): Expect expression."
      }
    case .interpreter(let e):
      switch e {
      case let .typeMismatch(op, right):
        "Operand must be a \(right). [line \(op.line)]"
      case let .binaryFailure(op, l, r):
        "Failed to perform \(op.type) between operands \(l) \(r). [line \(op.line)]"
      case let .divByZero(op, _, _): "error: division by zero. [line \(op.line)]"
      }
    }
  }
}

private func isEndStr(_ tk: Token) -> String {
  tk.type == .eof ? "end" : "'\(tk.lexeme)'"
}

public enum ScannerError: Swift.Error {
  case unexpectedCharacter(Int)
  case unterminatedString(Int)
}

public enum ParserError: Swift.Error {
  case expectExpressionAnd(Token, TokenType)
  case expectExpression(Token)
}

public enum InterpreterError: Swift.Error {
  case typeMismatch(Token, Value)
  case binaryFailure(Token, Value, Value)
  case divByZero(Token, Value, Value)
}
