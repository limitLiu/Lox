import struct Foundation.UUID

public indirect enum Expr {
  case assign(Assign)
  case binary(Binary)
  case call(Call)
  case get(Get)
  case grouping(Expr)
  case literal(Literal)
  case logical(Logical)
  case set(Set)
  case `super`(Super)
  case this(This)
  case unary(Unary)
  case variable(Variable)
}

extension Expr: Sendable, Hashable, Identifiable {
  public var id: UUID? {
    switch self {
    case let .assign(expr): expr.id
    case let .this(expr): expr.id
    case let .super(expr): expr.id
    case let .variable(expr): expr.id
    default: .none
    }
  }
}

public extension Expr {
  struct Assign: Sendable, Hashable, Identifiable {
    public let id = UUID()
    let name: Token
    let value: Expr
  }

  struct Binary: Sendable, Hashable {
    let left: Expr
    let op: Token
    let right: Expr
  }

  struct Call: Sendable, Hashable {
    let callee: Expr
    let paren: Token
    let arguments: [Expr]
  }

  struct Get: Sendable, Hashable {
    let object: Expr
    let name: Token
  }

  enum Literal: Sendable, Hashable {
    case number(Double)
    case string(String)
    case `true`
    case `false`
    case `nil`
  }

  struct Logical: Sendable, Hashable {
    let left: Expr
    let op: Token
    let right: Expr
  }

  struct Set: Sendable, Hashable {
    let object: Expr
    let name: Token
    let value: Expr
  }

  struct This: Sendable, Hashable, Identifiable {
    public let id = UUID()
    let keyword: Token
  }

  struct Super: Sendable, Hashable, Identifiable {
    public let id = UUID()
    let keyword: Token
    let method: Token
  }

  struct Unary: Sendable, Hashable {
    let op: Token
    let right: Expr
  }

  struct Variable: Sendable, Hashable, Identifiable {
    public let id = UUID()
    let name: Token
  }
}
