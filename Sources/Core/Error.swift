public enum LoxError: Swift.Error {
  case scanner(ScannerError)
  case parser(ParserError)
  case interpreter(InterpreterError)
  case environment(EnvironmentError)
}

public typealias Result<T> = Swift.Result<T, LoxError>

extension LoxError {
  private func report(line: Int, `where`: String, message: String) -> String {
    "[line \(line)] Error\(`where`): \(message)"
  }
}

extension LoxError: CustomStringConvertible {
  public var description: String {
    switch self {
    case .scanner(let e):
      switch e {
      case .unexpectedCharacter(let line):
        report(line: line, where: "", message: "Unexpected character.")
      case .unterminatedString(let line):
        report(line: line, where: "", message: "Unterminated string.")
      }
    case .parser(let e):
      switch e {
      case let .expectAfterValue(token, type):
        report(line: token.line, where: "", message: "Expect '\(type.description)' after value.")
      case let .expectAfterExpression(token, type):
        report(
          line: token.line,
          where: " at '\(isEndStr(token))'",
          message: "Expect '\(type.description)' after expression."
        )
      case let .expectExpression(token):
        report(
          line: token.line,
          where: " at '\(isEndStr(token))'",
          message: "Expect expression."
        )
      case let .expectVariableName(token):
        report(line: token.line, where: "", message: "Expect variable name.")
      case let .expectAfterVariableDeclaration(token, type):
        report(
          line: token.line,
          where: " at '\(isEndStr(token))'",
          message: "Expect '\(type.description)' after variable declaration."
        )
      case let .expectBlock(token, type):
        report(
          line: token.line,
          where: " at '\(isEndStr(token))'",
          message: "Expect '\(type.description)' after block."
        )
      case let .invalidAssignTarget(token):
        report(line: token.line, where: " at '\(isEndStr(token))'", message: "Invalid assignment target.")
      }
    case .interpreter(let e):
      switch e {
      case let .typeMismatch(op, right):
        "Operand must be a \(right). [line \(op.line)]"
      case let .binaryFailure(op, l, r):
        "Failed to perform \(op.type) between operands \(l) \(r). [line \(op.line)]"
      case let .divByZero(op, _, _): "error: division by zero. [line \(op.line)]"
      }
    case .environment(let e):
      switch e {
      case .undefinedVariable(let ident):
        "Undefined variable '\(ident)'."
      }
    }
  }
}

private func isEndStr(_ tk: Token) -> String {
  tk.type == .eof ? "end" : "\(tk.lexeme)"
}

public enum ScannerError: Swift.Error {
  case unexpectedCharacter(Int)
  case unterminatedString(Int)
}

public enum ParserError: Swift.Error {
  case expectAfterValue(Token, TokenType)
  case expectAfterExpression(Token, TokenType)
  case expectExpression(Token)
  case expectVariableName(Token)
  case expectAfterVariableDeclaration(Token, TokenType)
  case expectBlock(Token, TokenType)
  case invalidAssignTarget(Token)
}

public enum InterpreterError: Swift.Error {
  case typeMismatch(Token, Value)
  case binaryFailure(Token, Value, Value)
  case divByZero(Token, Value, Value)
}

public enum EnvironmentError: Swift.Error {
  case undefinedVariable(String)
}
