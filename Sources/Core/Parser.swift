public class Parser {
  private let tokens: [Token]
  private var current: Int = 0

  public init(_ tokens: [Token]) {
    self.tokens = tokens
  }

  public func parse() -> Result<[Stmt]> {
    var statements: [Stmt] = []
    while !isAtEnd {
      do {
        statements.append(try declaration())
      } catch {
        synchronize()
        return .failure(error)
      }
    }
    return .success(statements)
  }
}

extension Parser {
  private func expression() throws(LoxError) -> Expr {
    try assignment()
  }

  private func or() throws(LoxError) -> Expr {
    var expr = try and()
    while match(.or) {
      let op = previous
      let right = try and()
      expr = .logical(Expr.Logical(left: expr, op: op, right: right))
    }
    return expr
  }

  private func and() throws(LoxError) -> Expr {
    var expr = try equality()
    while match(.and) {
      let op = previous
      let right = try equality()
      expr = .logical(Expr.Logical(left: expr, op: op, right: right))
    }
    return expr
  }

  private func equality() throws(LoxError) -> Expr {
    var expr = try comparison()
    while match(.bangEqual, .equalEqual) {
      let op = previous
      let right = try comparison()
      expr = .binary(Expr.Binary(left: expr, op: op, right: right))
    }
    return expr
  }

  private func comparison() throws(LoxError) -> Expr {
    var expr = try term()
    while match(.greater, .greaterEqual, .less, .lessEqual) {
      let op = previous
      let right = try term()
      expr = .binary(Expr.Binary(left: expr, op: op, right: right))
    }
    return expr
  }

  private func term() throws(LoxError) -> Expr {
    var expr = try factor()
    while match(.minus, .plus) {
      let op = previous
      let right = try factor()
      expr = .binary(Expr.Binary(left: expr, op: op, right: right))
    }
    return expr
  }

  private func factor() throws(LoxError) -> Expr {
    var expr = try unary()
    while match(.slash, .star) {
      let op = previous
      let right = try unary()
      expr = .binary(Expr.Binary(left: expr, op: op, right: right))
    }
    return expr
  }

  private func unary() throws(LoxError) -> Expr {
    while match(.minus, .plus) {
      let op = previous
      let right = try unary()
      return .unary(Expr.Unary(op: op, right: right))
    }
    return try call()
  }

  private func finishCall(callee expr: Expr) throws(LoxError) -> Expr {
    var arguments: [Expr] = []
    if !check(.rightParen) {
      repeat {
        if arguments.count >= 255 {
          throw .parser(error(.maximumArgumentCounts))
        }
        arguments.append(try expression())
      } while match(.comma)
    }
    let paren = try consume(type: .rightParen, err: .expectAfter(.rightParen, "value"))
    return .call(Expr.Call(callee: expr, paren: paren, arguments: arguments))
  }

  private func call() throws(LoxError) -> Expr {
    var expr = try primary()
    while true {
      if match(.leftParen) {
        expr = try finishCall(callee: expr)
      } else {
        break
      }
    }
    return expr
  }

  private func primary() throws(LoxError) -> Expr {
    let current = advance()
    switch current.type {
    case .false: return .literal(.false)
    case .true: return .literal(.true)
    case .nil: return .literal(.nil)
    case .number(let n): return .literal(.number(n))
    case .str(let s): return .literal(.string(s))
    case .ident(_): return .variable(current)
    case .leftParen:
      let output = try expression()
      try consume(type: .rightParen, err: .expectAfter(.rightParen, "expression"))
      return Expr.grouping(output)
    default: throw .parser(error(.expectExpression))
    }
  }
}

extension Parser {
  private func statement() throws(LoxError) -> Stmt {
    if match(.for) { return try forStatement() }
    if match(.if) { return try ifStatement() }
    if match(.print) { return try printStatement() }
    if match(.return) { return try returnStatement() }
    if match(.while) { return try whileStatement() }
    if match(.leftBrace) { return .block(Stmt.Block(statements: try blockStatement())) }
    return try expressionStatement()
  }

  private func declaration() throws(LoxError) -> Stmt {
    if match(.func) { return try function(kind: "function") }
    if match(.var) { return try varDeclaration() }
    return try statement()
  }

  private func function(kind: String) throws(LoxError) -> Stmt {
    let name = try consume(type: .ident(""), err: .expect(kind))
    try consume(type: .leftParen, err: .expectAfter(.leftParen, "\(kind) name"))
    var parameters: [Token] = []
    if !check(.rightParen) {
      repeat {
        if parameters.count >= 255 { throw .parser(error(.maximumArgumentCounts)) }
        parameters.append(try consume(type: .ident(""), err: .expect("parameter")))
      } while match(.comma)
    }
    try consume(type: .rightParen, err: .expectAfter(.rightParen, "parameters"))
    try consume(type: .leftBrace, err: .expectBefore(.leftBrace, "\(kind) body"))
    let body = try blockStatement()
    return .function(Stmt.Function(name: name, params: parameters, body: body))
  }

  private func varDeclaration() throws(LoxError) -> Stmt {
    let name = try consume(type: .ident(""), err: .expectVariableName)
    var initializer: Expr? = .none
    if match(.equal) {
      initializer = try expression()
    }
    try consume(type: .semicolon, err: .expectAfter(.semicolon, "variable declaration"))
    return .var(Stmt.Var(name: name, initializer: initializer))
  }
}

extension Parser {
  private func ifStatement() throws(LoxError) -> Stmt {
    let condition = try expression()
    let thenBranch: Stmt = try statement()
    var elseBranch: Stmt?
    if match(.else) {
      elseBranch = try statement()
    }
    return .if(Stmt.If(condition: condition, thenBranch: thenBranch, elseBranch: elseBranch))
  }

  private func printStatement() throws(LoxError) -> Stmt {
    let value = try expression()
    try consume(type: .semicolon, err: .expectAfter(.semicolon, "value"))
    return .print(value)
  }

  private func returnStatement() throws(LoxError) -> Stmt {
    let keyword = previous
    var value: Expr?
    if !check(.semicolon) {
      value = try expression()
    }
    try consume(type: .semicolon, err: .expectAfter(.semicolon, "return value"))
    return Stmt.return(Stmt.Return(keyword: keyword, value: value))
  }

  private func whileStatement() throws(LoxError) -> Stmt {
    let condition = try expression()
    let body = try statement()
    return .while(Stmt.While(condition: condition, body: body))
  }

  private func forStatement() throws(LoxError) -> Stmt {
    try consume(type: .leftParen, err: .expectAfter(.leftParen, "block"))
    let initializer: Stmt?
    if match(.semicolon) {
      initializer = .none
    } else if match(.var) {
      initializer = try varDeclaration()
    } else {
      initializer = try expressionStatement()
    }
    let condition =
      if !check(.semicolon) {
        try expression()
      } else {
        Expr.literal(.true)
      }

    try consume(type: .semicolon, err: .expectAfter(.semicolon, "expression"))
    let increment: Expr? =
      if !check(.rightParen) {
        try expression()
      } else {
        .none
      }
    try consume(type: .rightParen, err: .expectAfter(.rightParen, "expression"))
    var body = try statement()
    if let increment {
      body = .block(Stmt.Block(statements: [body, .expr(increment)]))
    }
    body = .while(Stmt.While(condition: condition, body: body))
    if let initializer {
      body = .block(Stmt.Block(statements: [initializer, body]))
    }
    return body
  }

  private func blockStatement() throws(LoxError) -> [Stmt] {
    var statements: [Stmt] = []
    while !check(.rightBrace), !isAtEnd {
      statements.append(try declaration())
    }
    try consume(type: .rightBrace, err: .expectAfter(.rightBrace, "block"))
    return statements
  }

  private func expressionStatement() throws(LoxError) -> Stmt {
    let expr = try expression()
    try consume(type: .semicolon, err: .expectAfter(.semicolon, "expression"))
    return .expr(expr)
  }

  private func assignment() throws(LoxError) -> Expr {
    let expr = try or()
    if match(.equal) {
      let equals = previous
      let value = try assignment()
      if case let .variable(t) = expr {
        return .assign(Expr.Assign(name: t, value: value))
      }
      throw .parser(error(.invalidAssignTarget, token: equals))
    }
    return expr
  }
}

extension Parser {
  private func match(_ types: TokenType...) -> Bool {
    for t in types where check(t) {
      advance()
      return true
    }
    return false
  }

  private func check(_ type: TokenType) -> Bool {
    if isAtEnd {
      false
    } else {
      peek().type =~ type
    }
  }

  @discardableResult
  private func advance() -> Token {
    if !isAtEnd {
      current += 1
    }
    return previous
  }

  private var isAtEnd: Bool {
    peek().type == .eof
  }

  private func peek() -> Token {
    tokens[current]
  }

  private var previous: Token {
    tokens[current - 1]
  }

  @discardableResult
  private func consume(type: TokenType, err: ParserError.Kind) throws(LoxError) -> Token {
    if check(type) { return advance() }
    throw .parser(error(err))
  }

  private func synchronize() {
    advance()
    while !isAtEnd {
      if previous.type == .semicolon { return }
      switch peek().type {
      case .class, .func,
        .var,
        .for,
        .if,
        .while,
        .print,
        .return:
        return
      default:
        advance()
      }
    }
  }

  private func error(_ kind: ParserError.Kind, token: Token? = .none) -> ParserError {
    ParserError(kind: kind, token: token ?? peek())
  }
}
