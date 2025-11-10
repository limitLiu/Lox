public indirect enum Expr {
  case assign(name: Token, value: Expr)
  case binary(left: Expr, op: Token, right: Expr)
  case call(callee: Expr, paren: Token, arguments: [Expr])
  case get(object: Expr, name: Token)
  case grouping(Expr)
  case literal(Literal)
  case logical(left: Expr, op: Token, right: Expr)
  case set(object: Expr, name: Token, value: Expr)
  case `super`(keyword: Token, method: Token)
  case this(Token)
  case unary(op: Token, right: Expr)
  case variable(Token)
}

extension Expr {
  public enum Literal {
    case number(Double)
    case string(String)
    case `true`
    case `false`
    case `nil`
  }
}
