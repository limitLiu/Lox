import protocol Foundation.LocalizedError

protocol LoxErrorProtocol: LocalizedError {
  var line: Int { get }
  var location: String { get }
  var message: String { get }
}

extension LoxErrorProtocol {
  public var errorDescription: String? {
    "[line \(line)] Error \(location): \(message)"
  }

  var location: String { "" }
}

public enum LoxError: Swift.Error {
  case scanner(ScannerError)
  case parser(ParserError)
  case interpreter(InterpreterError)
  case environment(EnvironmentError)
  case `return`(Return)
  case resolver(ResolverError)
  case unknown(any Error)
}

public typealias Result<T> = Swift.Result<T, LoxError>

extension LoxError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case let .scanner(e): e.errorDescription
    case let .parser(e): e.errorDescription
    case let .interpreter(e): e.errorDescription
    case let .environment(e): e.errorDescription
    case let .resolver(e): e.errorDescription
    case let .unknown(e): e.localizedDescription
    case let .return(ret): ret.value.description
    }
  }
}

public enum ScannerError: LoxErrorProtocol {
  case unexpectedCharacter(Int)
  case unterminatedString(Int)

  var line: Int {
    switch self {
    case let .unexpectedCharacter(l), let .unterminatedString(l): l
    }
  }

  var message: String {
    switch self {
    case .unexpectedCharacter: "Unexpected character."
    case .unterminatedString: "Unterminated string."
    }
  }
}

public struct ParserError: LoxErrorProtocol {
  public enum Kind: Sendable {
    case expectBefore(TokenType, String)
    case expectAfter(TokenType, String)
    case expectExpression
    case expectVariableName
    case invalidAssignTarget
    case maximumArgumentCounts
    case expect(String)

    var message: String {
      switch self {
      case .expectBefore(let type, let kind): "Expect '\(type)' before \(kind)."
      case .expectAfter(let type, let kind): "Expect '\(type)' after \(kind)."
      case .expectVariableName: "Expect variable name."
      case .expectExpression: "Expect expression."
      case .invalidAssignTarget: "Invalid assignment target."
      case .maximumArgumentCounts: "Can't have more than 255 arguments."
      case .expect(let s): "Expect \(s) name."
      }
    }
  }

  public let kind: Kind
  public let token: Token

  var location: String {
    token.type == .eof ? "at end" : "at '\(token.lexeme)'"
  }

  var line: Int { token.line }

  var message: String { kind.message }
}

public enum InterpreterError: LoxErrorProtocol {
  var line: Int { token.line }

  var message: String {
    switch self {
    case let .typeMismatch(_, right):
      "Operand must be a \(right)."
    case let .binaryFailure(op, l, r):
      "Failed to perform \(op.type) between operands \(l) \(r)."
    case .divByZero(_, _, _): "error: division by zero."
    case .canNotCallable(_):
      "Can only call functions and classes."
    case let .incorrectArgsCount(_, arity, argsCount):
      "Expected \(arity) arguments but got \(argsCount)."
    }
  }

  private var token: Token {
    switch self {
    case .typeMismatch(let t, _): t
    case .binaryFailure(let t, _, _): t
    case .divByZero(let t, _, _): t
    case .canNotCallable(let t): t
    case .incorrectArgsCount(let t, _, _): t
    }
  }

  case typeMismatch(Token, Value)
  case binaryFailure(Token, Value, Value)
  case divByZero(Token, Value, Value)
  case canNotCallable(Token)
  case incorrectArgsCount(Token, Int, Int)
}

public enum EnvironmentError: LoxErrorProtocol {
  var line: Int { 1 }

  var message: String { "" }

  public var errorDescription: String? {
    switch self {
    case .undefinedVariable(let ident): "Undefined variable '\(ident)'."
    }
  }

  case undefinedVariable(String)
}

public enum ResolverError: LoxErrorProtocol {
  case canNotReadLocalVariable(Token)
  case alreadyVariableSameName(Token)
  case returnFromTopLevel(Token)

  var line: Int { token.line }

  var message: String {
    switch self {
    case .canNotReadLocalVariable: "Can't read local variable in its own initializer."
    case .alreadyVariableSameName: "Already variable with this name in this scope."
    case .returnFromTopLevel: "Can't return from top-level code."
    }
  }

  private var token: Token {
    switch self {
    case .canNotReadLocalVariable(let t): t
    case .alreadyVariableSameName(let t): t
    case .returnFromTopLevel(let t): t
    }
  }
}

public struct Return: Swift.Error {
  let value: Value
}
