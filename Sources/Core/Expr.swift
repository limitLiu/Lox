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
  case variable(Token)
}

extension Expr: Sendable {}

extension Expr {
  public struct Assign: Sendable {
    let name: Token
    let value: Expr
  }

  public struct Binary: Sendable {
    let left: Expr
    let op: Token
    let right: Expr
  }

  public struct Call: Sendable {
    let callee: Expr
    let paren: Token
    let arguments: [Expr]
  }

  public struct Get: Sendable {
    let object: Expr
    let name: Token
  }

  public enum Literal: Sendable {
    case number(Double)
    case string(String)
    case `true`
    case `false`
    case `nil`
  }

  public struct Logical: Sendable {
    let left: Expr
    let op: Token
    let right: Expr
  }

  public struct Set: Sendable {
    let object: Expr
    let name: Token
    let value: Expr
  }

  public struct Super: Sendable {
    let keyword: Token
    let method: Token
  }

  public struct Unary: Sendable {
    let op: Token
    let right: Expr
  }
}
