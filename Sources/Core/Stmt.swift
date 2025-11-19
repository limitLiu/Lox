public indirect enum Stmt {
  case block(Block)
  case expr(Expr)
  case function(Function)
  case `if`(If)
  case print(Expr)
  case `return`(Return)
  case `var`(Var)
  case `while`(While)
}

extension Stmt: Sendable {}

extension Stmt {
  public struct Block: Sendable {
    let statements: [Stmt]
  }

  public struct Function: Sendable {
    let name: Token
    let params: [Token]
    let body: [Stmt]
  }

  public struct If: Sendable {
    let condition: Expr
    let thenBranch: Stmt
    let elseBranch: Stmt?
  }

  public struct Return: Sendable {
    let keyword: Token
    let value: Expr?
  }

  public struct Var: Sendable {
    let name: Token
    var initializer: Expr?
  }

  public struct While: Sendable {
    let condition: Expr
    let body: Stmt
  }
}
