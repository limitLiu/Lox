public indirect enum Stmt {
  case block(Block)
  case expr(Expr)
  case `if`(If)
  case print(Expr)
  case `var`(Var)
  case `while`(While)
}

extension Stmt {
  public struct Block {
    let statements: [Stmt]
  }

  public struct If {
    let condition: Expr
    let thenBranch: Stmt
    let elseBranch: Stmt?
  }

  public struct Var {
    let name: Token
    var initializer: Expr?
  }

  public struct While {
    let condition: Expr
    let body: Stmt
  }
}
