public enum LoxError {
  case unexpectedCharacter(Int)
  case unterminatedString(Int)
  case expectExpressionAnd(Token, TokenType)
  case expectExpression(Token)
}

public typealias Result<T> = Swift.Result<T, LoxError>

extension LoxError: Swift.Error {}

extension LoxError: CustomStringConvertible {
  public var description: String {
    switch self {
    case .unexpectedCharacter(let line):
      "[line \(line)] Error: Unexpected character."
    case .unterminatedString(let line):
      "[line \(line)] Error: Unterminated string."
    case let .expectExpressionAnd(token, type):
      "[line \(token.line)] Error at '\(token.lexeme)': Expect '\(type.description)' after expression."
    case let .expectExpression(token):
      "[line \(token.line)] Error at '\(token.lexeme)': Expect expression."
    }
  }
}
