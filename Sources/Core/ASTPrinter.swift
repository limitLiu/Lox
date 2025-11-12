public struct ASTPrinter {
  public init() {}

  public func print(expr: Expr) -> String {
    switch expr {
    case let .assign(name, value):
      parenthesize(name: name.lexeme, expressions: value)
    case let .binary(left, op, right):
      parenthesize(name: op.lexeme, expressions: left, right)
    case let .call(callee, _, arguments):
      parenthesize(name: "call", parts: [print(expr: callee)] + arguments.map { print(expr: $0) })
    case let .get(object, name):
      parenthesize(name: ".", parts: [print(expr: object), name.lexeme])
    case .grouping(let expr):
      parenthesize(name: "group", expressions: expr)
    case let .literal(literal):
      switch literal {
      case .number(let n): String(describing: n)
      case .string(let s): s
      case .true: "true"
      case .false: "false"
      case .nil: "nil"
      }
    case let .logical(left, op, right):
      parenthesize(name: op.lexeme, expressions: left, right)
    case let .set(object, name, value):
      parenthesize(name: "=", parts: [print(expr: object), name.lexeme, print(expr: value)])
    case let .super(_, method):
      parenthesize(name: "super", parts: [method.lexeme])
    case .this: "this"
    case let .unary(op, right):
      parenthesize(name: op.lexeme, expressions: right)
    case .variable(let nm): nm.lexeme
    }
  }

}

extension ASTPrinter {
  private func parenthesize(name: String, expressions: Expr...) -> String {
    var builder = "(\(name)"
    for expr in expressions {
      builder += " "
      builder += print(expr: expr)
    }
    builder += ")"
    return builder
  }

  private func parenthesize(name: String, parts: [String]) -> String {
    var builder = "(\(name)"
    for part in parts {
      builder += " "
      builder += part
    }
    builder += ")"
    return builder
  }
}
