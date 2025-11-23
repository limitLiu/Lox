import struct Foundation.Date
import struct Synchronization.Mutex

public final class Interpreter: Sendable {
  private struct State {
    var environment: Environment?
    var locals: [Expr: Int] = [:]
  }

  public init() {
    globals = Environment()
    environment = globals
    globals.define(
      "clock",
      forValue: .callable(
        AnyCallable(
          NativeFn(
            arity: 0,
            closure: { _, _ in
              .number(Date().timeIntervalSince1970)
            }
          )
        )
      )
    )
  }

  let globals: Environment

  private let state = Mutex(State())

  private var environment: Environment? {
    get { state.withLock { $0.environment } }
    set { state.withLock { $0.environment = newValue } }
  }

  private var locals: [Expr: Int] {
    get { state.withLock { $0.locals } }
    set { state.withLock { $0.locals = newValue } }
  }

  public func interpret(statements: [Stmt]) {
    do {
      for statement in statements {
        try execute(statement)
      }
    } catch {
      print(error.localizedDescription)
    }
  }
}

extension Interpreter {
  @discardableResult
  private func evaluate(expr: Expr) throws(LoxError) -> Value {
    switch expr {
    case let .assign(assign): try evaluate(assign: assign)
    case let .binary(binary): try evaluate(binary: binary)
    case let .call(call): try evaluate(call: call)
    case .get(_): Value.nil
    case let .grouping(grouping): try evaluate(expr: grouping)
    case let .literal(literal): try evaluate(literal: literal)
    case let .logical(logical): try evaluate(logical: logical)
    case let .set(s): try evaluate(set: s)
    case .super(_): Value.nil
    case .this(_): Value.nil
    case let .unary(unary): try evaluate(unary: unary)
    case let .variable(variable): try evaluate(var: variable)
    }
  }

  private func evaluate(call: Expr.Call) throws(LoxError) -> Value {
    let callee = try evaluate(expr: call.callee)
    let arguments = try call.arguments.map(evaluate(expr:))
    guard case let .callable(fn) = callee else {
      throw .interpreter(.canNotCallable(call.paren))
    }
    guard arguments.count == fn.arity else {
      throw .interpreter(.incorrectArgsCount(call.paren, fn.arity, arguments.count))
    }
    do {
      return try fn.call(interpreter: self, arguments: arguments)
    } catch let e as LoxError {
      throw e
    } catch {
      throw .unknown(error)
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
    let left = try evaluate(expr: expr.left)
    return switch (expr.op.type, left.isTruthy) {
    case (.or, true), (.and, false): left
    default: try evaluate(expr: expr.right)
    }
  }

  private func evaluate(set expr: Expr.Set) throws(LoxError) -> Value {
    .nil
  }

  private func evaluate(unary expr: Expr.Unary) throws(LoxError) -> Value {
    let right = try evaluate(expr: expr.right)
    return switch (expr.op.type, right) {
    case (.minus, .number(let n)): .number(-n)
    case (.minus, _): throw .interpreter(.typeMismatch(expr.op, right))
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

  private func evaluate(`var` variable: Expr.Variable) throws(LoxError) -> Value {
    if let distance = locals[.variable(variable)] {
      (try environment?.get(at: distance, name: variable.name.lexeme)) ?? .nil
    } else {
      try globals.get(variable.name) ?? .nil
    }
  }

  private func evaluate(assign expr: Expr.Assign) throws(LoxError) -> Value {
    let value = try evaluate(expr: expr.value)
    if let distance = locals[.assign(expr)] {
      environment?.assign(at: distance, name: expr.name, value: value)
    } else {
      try globals.assign(expr.name, forValue: value)
    }
    return value
  }
}

extension Interpreter {
  public func resolve(expr: Expr, depth: Int) {
    locals[expr] = depth
  }

  private func execute(_ stmt: Stmt) throws(LoxError) {
    switch stmt {
    case let .block(block): try execute(block.statements, withEnv: Environment(enclosing: environment))
    case let .expr(expr): try evaluate(expr: expr)
    case let .if(i): try evaluate(if: i)
    case let .print(expr): Swift.print(try evaluate(expr: expr))
    case let .return(ret): try evaluate(return: ret)
    case let .var(statement): try evaluate(var: statement)
    case let .while(statement): try evaluate(while: statement)
    case let .function(fn): try evaluate(fn: fn)
    }
  }

  private func evaluate(`var` stmt: Stmt.Var) throws(LoxError) {
    let value = try stmt.initializer.map(evaluate(expr:))
    environment?.define(stmt.name.lexeme, forValue: value)
  }

  private func evaluate(`while` stmt: Stmt.While) throws(LoxError) {
    while (try evaluate(expr: stmt.condition)).isTruthy {
      try execute(stmt.body)
    }
  }

  private func evaluate(fn stmt: Stmt.Function) throws(LoxError) {
    if let environment {
      let fn = Fn(declaration: stmt, closure: environment)
      environment.define(stmt.name.lexeme, forValue: .callable(AnyCallable(fn)))
    }
  }

  func execute(_ statements: [Stmt], withEnv env: Environment) throws(LoxError) {
    let previous = environment
    environment = env
    defer { environment = previous }
    for statement in statements {
      try execute(statement)
    }
  }

  private func evaluate(`if` stmt: Stmt.If) throws(LoxError) {
    if (try evaluate(expr: stmt.condition)).isTruthy {
      try execute(stmt.thenBranch)
    } else if let statement = stmt.elseBranch {
      try execute(statement)
    }
  }

  private func evaluate(`return` stmt: Stmt.Return) throws(LoxError) {
    var value: Value = .nil
    if let v = stmt.value {
      value = try evaluate(expr: v)
    }
    throw .return(Return(value: value))
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
