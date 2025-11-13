public final class Interpreter {
  public init() {}

  public func interpret(expr: Expr) {
    do {
      let value = try evaluate(expr: expr)
      print(value)
    } catch {
      print(error)
    }
  }
}

extension Interpreter {
  private func evaluate(expr: Expr) throws(LoxError) -> Value {
    switch expr {
    case .assign(_):
      Value.nil
    case let .binary(binary):
      try evaluate(binary: binary)
    case .call(_):
      Value.nil
    case .get(_):
      Value.nil
    case let .grouping(grouping):
      try evaluate(expr: grouping)
    case let .literal(literal):
      try evaluate(literal: literal)
    case let .logical(logical):
      try evaluate(logical: logical)
    case let .set(s):
      try evaluate(set: s)
    case .super(_):
      Value.nil
    case .this(_):
      Value.nil
    case let .unary(unary):
      try evaluate(unary: unary)
    case .variable(_):
      Value.nil
    }
  }

  private func evaluate(literal expr: Expr.Literal) throws(LoxError) -> Value {
    switch expr {
    case .number(let n): .number(n)
    case .string(let s): .string(s)
    case .true: .boolean(true)
    case .false: .boolean(false)
    case .nil: .nil
    }
  }

  private func evaluate(logical expr: Expr.Logical) throws(LoxError) -> Value {
    .nil
  }

  private func evaluate(set expr: Expr.Set) throws(LoxError) -> Value {
    .nil
  }

  private func evaluate(unary expr: Expr.Unary) throws(LoxError) -> Value {
    let right = try evaluate(expr: expr.right)
    return switch (expr.op.type, right) {
    case (.minus, .number(let n)): .number(-n)
    case (.minus, _): throw LoxError.interpreter(.typeMismatch(expr.op, right))
    case (.bang, _): .boolean(!right.isTruthy)
    default: Value.boolean(false)
    }
  }

  private func evaluate(binary expr: Expr.Binary) throws(LoxError) -> Value {
    let left = try evaluate(expr: expr.left)
    let right = try evaluate(expr: expr.right)
    return switch (expr.op.type, left, right) {
    case let (.minus, .number(l), .number(r)): .number(l - r)
    case let (.plus, .number(l), .number(r)): .number(l + r)
    case let (.slash, .number(l), .number(r)):
      switch (l, r) {
      case (0, 0): .number(l / r)
      case (_, 0): throw .interpreter(.divByZero(expr.op, left, right))
      default: .number(l / r)
      }
    case let (.star, .number(l), .number(r)): .number(l * r)

    case let (.plus, .string(l), .string(r)): .string(l + r)

    case let (.less, .number(l), .number(r)): .boolean(l < r)
    case let (.lessEqual, .number(l), .number(r)): .boolean(l <= r)
    case let (.greater, .number(l), .number(r)): .boolean(l > r)
    case let (.greaterEqual, .number(l), .number(r)): .boolean(l >= r)

    case (.equalEqual, _, _): .boolean(left == right)
    case (.bangEqual, _, _): .boolean(left != right)

    default: throw .interpreter(.binaryFailure(expr.op, left, right))
    }
  }
}

extension Value {
  fileprivate var isTruthy: Bool {
    switch self {
    case .boolean(let b): b
    case .nil: false
    default: true
    }
  }
}
