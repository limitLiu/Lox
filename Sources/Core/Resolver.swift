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
  public func resolve(stmts: [Stmt]) throws(LoxError) {
    for stmt in stmts {
      try resolve(stmt: stmt)
    }
  }

  private func resolve(stmt: Stmt) throws(LoxError) {
    switch stmt {
    case let .block(stmt):
      beginScope()
      defer { endScope() }
      try resolve(stmts: stmt.statements)
    case let .var(stmt):
      try declare(name: stmt.name)
      if let initializer = stmt.initializer {
        try resolve(expr: initializer)
      }
      define(name: stmt.name)
    case let .function(stmt):
      try declare(name: stmt.name)
      define(name: stmt.name)
      try resolve(fn: stmt, kind: .fn)
    case let .expr(expr): try resolve(expr: expr)
    case let .if(stmt):
      try resolve(expr: stmt.condition)
      try resolve(stmt: stmt.thenBranch)
      if let elseBranch = stmt.elseBranch {
        try resolve(stmt: elseBranch)
      }
    case let .print(expr): try resolve(expr: expr)
    case let .return(stmt):
      if currentFn == FunctionType.none {
        throw .resolver(.returnFromTopLevel(stmt.keyword))
      }
      if let value = stmt.value {
        try resolve(expr: value)
      }
    case let .while(stmt):
      try resolve(expr: stmt.condition)
      try resolve(stmt: stmt.body)
    case let .class(stmt):
      try declare(name: stmt.name)
      define(name: stmt.name)
    }
  }
}

// MARK: - Expr

extension Resolver {
  private func resolve(expr: Expr) throws(LoxError) {
    switch expr {
    case let .variable(variable):
      if !scopes.isEmpty, scopes.top?[variable.name.lexeme] == false {
        throw .resolver(.canNotReadLocalVariable(variable.name))
      }
      resolve(local: expr, name: variable.name)
    case let .assign(assign):
      try resolve(expr: assign.value)
      resolve(local: expr, name: assign.name)
    case let .binary(binary):
      try resolve(expr: binary.left)
      try resolve(expr: binary.right)
    case let .call(call):
      try resolve(expr: call.callee)
      for argument in call.arguments {
        try resolve(expr: argument)
      }
    case let .grouping(grouping): try resolve(expr: grouping)
    case .literal: break
    case let .logical(logical):
      try resolve(expr: logical.left)
      try resolve(expr: logical.right)
    case let .unary(unary): try resolve(expr: unary.right)
    case let .get(expr): try resolve(expr: expr.object)
    case let .set(expr):
      try resolve(expr: expr.value)
      try resolve(expr: expr.object)
    case .this, .super: break
    }
  }
}

// MARK: - Helpers

extension Resolver {
  private func beginScope() { scopes.push([:]) }

  private func endScope() { scopes.pop() }

  private func declare(name: Token) throws(LoxError) {
    if scopes.isEmpty { return }
    if scopes.top?[name.lexeme] != nil {
      throw .resolver(.alreadyVariableSameName(name))
    }
    scopes.top?[name.lexeme] = false
  }

  private func define(name: Token) {
    if scopes.isEmpty { return }
    scopes.top?[name.lexeme] = true
  }

  private func resolve(local expr: Expr, name: Token) {
    for i in stride(from: scopes.count - 1, through: 0, by: -1) {
      let scope = scopes[i]
      if scope.keys.contains(name.lexeme) {
        let depth = scopes.count - 1 - i
        interpreter.resolve(expr: expr, depth: depth)
        return
      }
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
    try resolve(stmts: fn.body)
    endScope()
    currentFn = enclosingFn
  }
}
