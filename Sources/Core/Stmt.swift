public indirect enum Stmt {
  case block(Block)
  case `class`(Class)
  case expr(Expr)
  case function(Function)
  case `if`(If)
  case print(Expr)
  case `return`(Return)
  case `var`(Var)
  case `while`(While)
}

extension Stmt: Sendable {}

public extension Stmt {
  struct Block: Sendable {
    let statements: [Stmt]
  }

  struct Class: Sendable {
    let name: Token
    let methods: [Stmt]
  }

  struct Function: Sendable {
    let name: Token
    let params: [Token]
    let body: [Stmt]
  }

  struct If: Sendable {
    let condition: Expr
    let thenBranch: Stmt
    let elseBranch: Stmt?
  }

  struct Return: Sendable {
    let keyword: Token
    let value: Expr?
  }

  struct Var: Sendable {
    let name: Token
    var initializer: Expr?
  }

  struct While: Sendable {
    let condition: Expr
    let body: Stmt
  }
}
