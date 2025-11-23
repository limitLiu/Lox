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
  case this(Token)
  case unary(Unary)
  case variable(Variable)
}

extension Expr: Sendable, Hashable {}

extension Expr {
  public struct Assign: Sendable, Hashable {
    let name: Token
    let value: Expr
  }

  public struct Binary: Sendable, Hashable {
    let left: Expr
    let op: Token
    let right: Expr
  }

  public struct Call: Sendable, Hashable {
    let callee: Expr
    let paren: Token
    let arguments: [Expr]
  }

  public struct Get: Sendable, Hashable {
    let object: Expr
    let name: Token
  }

  public enum Literal: Sendable, Hashable {
    case number(Double)
    case string(String)
    case `true`
    case `false`
    case `nil`
  }

  public struct Logical: Sendable, Hashable {
    let left: Expr
    let op: Token
    let right: Expr
  }

  public struct Set: Sendable, Hashable {
    let object: Expr
    let name: Token
    let value: Expr
  }

  public struct Super: Sendable, Hashable {
    let keyword: Token
    let method: Token
  }

  public struct Unary: Sendable, Hashable {
    let op: Token
    let right: Expr
  }

  public struct Variable: Sendable, Hashable {
    let name: Token
  }
}
