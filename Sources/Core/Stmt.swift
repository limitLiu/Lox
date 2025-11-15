public indirect enum Stmt {
  case block(Block)
  case expr(Expr)
  case print(Expr)
  case `var`(Var)
}

extension Stmt {
  public struct Block {
    let statements: [Stmt]
  }

  public struct Var {
    let name: Token
    var initializer: Expr?
  }
}
