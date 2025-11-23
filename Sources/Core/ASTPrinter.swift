public struct ASTPrinter {
  public init() {}

  public func print(expr: Expr) -> String {
    switch expr {
    case let .assign(assign):
      parenthesize(name: assign.name.lexeme, expressions: assign.value)
    case let .binary(binary):
      parenthesize(name: binary.op.lexeme, expressions: binary.left, binary.right)
    case let .call(call):
      parenthesize(name: "call", parts: [print(expr: call.callee)] + call.arguments.map { print(expr: $0) })
    case let .get(g):
      parenthesize(name: ".", parts: [print(expr: g.object), g.name.lexeme])
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
    case let .logical(logical):
      parenthesize(name: logical.op.lexeme, expressions: logical.left, logical.right)
    case let .set(s):
      parenthesize(name: "=", parts: [print(expr: s.object), s.name.lexeme, print(expr: s.value)])
    case let .super(sp):
      parenthesize(name: "super", parts: [sp.method.lexeme])
    case .this: "this"
    case let .unary(unary):
      parenthesize(name: unary.op.lexeme, expressions: unary.right)
    case let .variable(tk): tk.name.lexeme
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
