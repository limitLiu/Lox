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

extension Expr {
  public struct Assign {
    let name: Token
    let value: Expr
  }

  public struct Binary {
    let left: Expr
    let op: Token
    let right: Expr
  }

  public struct Call {
    let callee: Expr
    let paren: Token
    let arguments: [Expr]
  }

  public struct Get {
    let object: Expr
    let name: Token
  }

  public enum Literal {
    case number(Double)
    case string(String)
    case `true`
    case `false`
    case `nil`
  }

  public struct Logical {
    let left: Expr
    let op: Token
    let right: Expr
  }

  public struct Set {
    let object: Expr
    let name: Token
    let value: Expr
  }

  public struct Super {
    let keyword: Token
    let method: Token
  }

  public struct Unary {
    let op: Token
    let right: Expr
  }
}
