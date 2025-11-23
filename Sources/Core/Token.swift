public struct Token: Sendable {
  let type: TokenType
  let lexeme: String
  let line: Int
}

extension Token: CustomStringConvertible {
  public var description: String {
    "\(line)> \(lexeme)\nType: \(type)"
  }
}

extension Token: Hashable {}

extension Token: Equatable {
  public static func == (lhs: Token, rhs: Token) -> Bool {
    lhs.type == rhs.type && lhs.lexeme == rhs.lexeme && lhs.line == rhs.line
  }
}

public nonisolated enum TokenType {
  case leftParen, rightParen, leftBrace, rightBrace, comma, dot, minus, plus, semicolon, slash, star
  case bang, bangEqual, equal, equalEqual, greater, greaterEqual, less, lessEqual
  case ident(String)
  case str(String)
  case number(Double)
  case and, `class`, `else`, `func`, `false`, `true`, `for`, `if`, `nil`, or, print, `return`, `super`, this, `var`,
    `while`
  case eof
}

extension TokenType: Hashable {}

extension TokenType: Sendable {}

extension TokenType: CustomStringConvertible {
  public var description: String {
    switch self {
    // Single-character tokens.
    case .leftParen: "("
    case .rightParen: ")"
    case .leftBrace: "{"
    case .rightBrace: "}"
    case .comma: ","
    case .dot: "."
    case .minus: "-"
    case .plus: "+"
    case .semicolon: ";"
    case .slash: "/"
    case .star: "*"
    // One or two character tokens.
    case .bang: "!"
    case .bangEqual: "!="
    case .equal: "="
    case .equalEqual: "=="
    case .greater: ">"
    case .greaterEqual: ">="
    case .less: "<"
    case .lessEqual: "<="
    // Literals.
    case let .ident(i): "ident(\(i))"
    case let .number(n): "number(\(n))"
    case let .str(s): "str(\(s))"
    // Keywords.
    case .and: "and"
    case .class: "class"
    case .else: "else"
    case .false: "false"
    case .for: "for"
    case .func: "fun"
    case .if: "if"
    case .nil: "nil"
    case .or: "or"
    case .print: "print"
    case .return: "return"
    case .super: "super"
    case .this: "this"
    case .true: "true"
    case .var: "var"
    case .while: "while"
    case .eof: "EOF"
    }
  }
}

extension TokenType: Equatable {
  public static func == (lhs: TokenType, rhs: TokenType) -> Bool {
    switch (lhs, rhs) {
    case (.ident(let a), .ident(let b)): a == b
    case (.str(let a), .str(let b)): a == b
    case (.number(let a), .number(let b)): a == b
    case (.leftParen, .leftParen): true
    case (.rightParen, .rightParen): true
    case (.leftBrace, .leftBrace): true
    case (.rightBrace, .rightBrace): true
    case (.comma, .comma): true
    case (.dot, .dot): true
    case (.minus, .minus): true
    case (.plus, .plus): true
    case (.semicolon, .semicolon): true
    case (.slash, .slash): true
    case (.star, .star): true
    case (.bang, .bang): true
    case (.bangEqual, .bangEqual): true
    case (.equal, .equal): true
    case (.equalEqual, .equalEqual): true
    case (.greater, .greater): true
    case (.greaterEqual, .greaterEqual): true
    case (.less, .less): true
    case (.lessEqual, .lessEqual): true
    case (.and, .and): true
    case (.class, .class): true
    case (.else, .else): true
    case (.func, .func): true
    case (.false, .false): true
    case (.true, .true): true
    case (.for, .for): true
    case (.if, .if): true
    case (.nil, .nil): true
    case (.or, .or): true
    case (.print, .print): true
    case (.return, .return): true
    case (.super, .super): true
    case (.this, .this): true
    case (.var, .var): true
    case (.while, .while): true
    case (.eof, .eof): true
    default: false
    }
  }
}

extension TokenType: CustomComparable {
  public static func =~ (lhs: TokenType, rhs: TokenType) -> Bool {
    switch (lhs, rhs) {
    case (.ident(_), .ident(_)): true
    default: lhs == rhs
    }
  }
}
