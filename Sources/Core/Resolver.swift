public final class Resolver {
  private let interpreter: Interpreter
  private var scopes = Stack<[String: Bool]>()
  private var currentFn = FunctionType.none

  public init(_ interpreter: Interpreter) {
    self.interpreter = interpreter
  }

  enum FunctionType {
    case none
    case fn
  }
}

extension Resolver {

  public func resolve(stmts: [Stmt]) -> Result<()> {
    do {
      for stmt in stmts {
        try resolve(stmt: stmt)
      }
      return .success(())
    } catch {
      return .failure(error)
    }
  }

  private func resolve(stmt: Stmt) throws(LoxError) {
    switch stmt {
    case .block(let stmt):
      beginScope()
      defer { endScope() }
      switch resolve(stmts: stmt.statements) {
      case .failure(let e): throw e
      default: break
      }
    case .var(let stmt):
      try declare(name: stmt.name)
      if let initializer = stmt.initializer {
        try resolve(expr: initializer)
      }
      define(name: stmt.name)
    case .function(let stmt):
      try declare(name: stmt.name)
      define(name: stmt.name)
      try resolve(fn: stmt, kind: .fn)
    case .expr(let expr): try resolve(expr: expr)
    case .if(let stmt):
      try resolve(expr: stmt.condition)
      try resolve(stmt: stmt.thenBranch)
      if let elseBranch = stmt.elseBranch {
        try resolve(stmt: elseBranch)
      }
    case .print(let expr): try resolve(expr: expr)
    case .return(let stmt):
      if currentFn == FunctionType.none {
        throw .resolver(.returnFromTopLevel(stmt.keyword))
      }
      if let value = stmt.value {
        try resolve(expr: value)
      }
    case .while(let stmt):
      try resolve(expr: stmt.condition)
      try resolve(stmt: stmt.body)
    }
  }
}

// MARK: - Expr

extension Resolver {
  private func resolve(expr: Expr) throws(LoxError) {
    switch expr {
    case .variable(let variable):
      if !scopes.isEmpty, scopes.peek?[variable.name.lexeme] == false {
        throw .resolver(.canNotReadLocalVariable(variable.name))
      }
      resolve(local: expr, name: variable.name)
    case .assign(let assign):
      try resolve(expr: assign.value)
      resolve(local: expr, name: assign.name)
    case .binary(let binary):
      try resolve(expr: binary.left)
      try resolve(expr: binary.right)
    case .call(let call):
      try resolve(expr: call.callee)
      for argument in call.arguments {
        try resolve(expr: argument)
      }
    case .grouping(let grouping): try resolve(expr: grouping)
    case .literal: break
    case .logical(let logical):
      try resolve(expr: logical.left)
      try resolve(expr: logical.right)
    case .unary(let unary): try resolve(expr: unary.right)
    case .get, .set, .this, .super:
      break
    }
  }
}

// MARK: - Helpers

extension Resolver {
  private func beginScope() { scopes.push([:]) }

  private func endScope() { scopes.pop() }

  private func declare(name: Token) throws(LoxError) {
    if scopes.isEmpty { return }
    if var scope = scopes.peek {
      scope[name.lexeme] = false
      if scope.keys.contains(name.lexeme) {
        throw .resolver(.alreadyVariableSameName(name))
      }
    }
  }

  private func define(name: Token) {
    if scopes.isEmpty { return }
    var scope = scopes.peek
    scope?[name.lexeme] = true
  }

  private func resolve(local expr: Expr, name: Token) {
    for (offset, element) in scopes.toArray().enumerated().reversed()
    where element.keys.contains(name.lexeme) {
      let depth = scopes.count - 1 - offset
      interpreter.resolve(expr: expr, depth: depth)
      return
    }
  }

  private func resolve(fn: Stmt.Function, kind: FunctionType) throws(LoxError) {
    let enclosingFn = currentFn
    currentFn = kind
    beginScope()
    for param in fn.params {
      try declare(name: param)
      define(name: param)
    }
    switch resolve(stmts: fn.body) {
    case .failure(let e): throw e
    default: break
    }
    endScope()
    currentFn = enclosingFn
  }
}
