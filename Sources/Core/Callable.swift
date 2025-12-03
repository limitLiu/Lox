public protocol Callable: Sendable, CustomStringConvertible {
  associatedtype T

  var arity: Int { get }
  func call(interpreter: Interpreter, arguments: [T]) throws -> T
}

public struct AnyCallable: Callable, Sendable {
  public typealias T = Value

  public var arity: Int {
    return _arity()
  }

  public func call(interpreter: Interpreter, arguments: [T]) throws -> T {
    try _call(interpreter, arguments)
  }

  public var description: String { _description() }

  private let _arity: @Sendable () -> Int
  private let _call: @Sendable (Interpreter, [T]) throws -> T
  private let _description: @Sendable () -> String

  public init<C: Callable>(_ c: C) where C.T == Value {
    self._arity = { c.arity }
    self._call = { interpreter, arguments in
      try c.call(interpreter: interpreter, arguments: arguments)
    }
    self._description = { c.description }
  }
}

struct Fn: Callable {
  typealias T = Value

  private let declaration: Stmt.Function
  private let closure: Environment

  var arity: Int {
    declaration.params.count
  }

  func call(interpreter: Interpreter, arguments: [T]) throws -> T {
    let environment = Environment(enclosing: closure)
    for (offset, parameter) in declaration.params.enumerated() {
      environment.define(parameter.lexeme, forValue: arguments[offset])
    }
    do {
      try interpreter.execute(declaration.body, withEnv: environment)
    } catch {
      switch error {
      case let .return(ret): return ret.value
      default: throw error
      }
    }
    return .nil
  }

  init(declaration: Stmt.Function, closure: Environment) {
    self.closure = closure
    self.declaration = declaration
  }

  var description: String {
    "<fn \(declaration.name.lexeme)>"
  }
}

struct NativeFn: Callable {
  typealias T = Value

  typealias Closure = @Sendable (Interpreter, [T]) throws -> T

  private let _arity: Int
  private let closure: Closure

  var arity: Int { _arity }

  func call(interpreter: Interpreter, arguments: [T]) throws -> T {
    try closure(interpreter, arguments)
  }

  init(arity: Int, closure: @escaping Closure) {
    self._arity = arity
    self.closure = closure
  }

  var description: String { "<native fn>" }
}
