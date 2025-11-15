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
    return try primary()
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
      try consume(type: .rightParen) { [unowned self] in
        .expectAfterExpression(peek(), $0)
      }
      return Expr.grouping(output)
    default: throw .parser(.expectExpression(peek()))
    }
  }
}

extension Parser {
  private func statement() throws(LoxError) -> Stmt {
    if match(.print) {
      return try printStatement()
    }
    if match(.leftBrace) {
      return .block(Stmt.Block(statements: try blockStatement()))
    }
    return try expressionStatement()
  }

  private func declaration() throws(LoxError) -> Stmt {
    if match(.var) {
      return try varDeclaration()
    }
    return try statement()
  }

  private func varDeclaration() throws(LoxError) -> Stmt {
    let name = try consume(type: .ident("")) { [unowned self] _ in
      .expectVariableName(peek())
    }
    var initializer: Expr? = .none
    if match(.equal) {
      initializer = try expression()
    }
    try consume(type: .semicolon) { [unowned self] in
      .expectAfterVariableDeclaration(peek(), $0)
    }
    return .var(Stmt.Var(name: name, initializer: initializer))
  }
}

extension Parser {
  private func printStatement() throws(LoxError) -> Stmt {
    let value = try expression()
    try consume(type: .semicolon) { [unowned self] in
      .expectAfterValue(peek(), $0)
    }
    return .print(value)
  }

  private func blockStatement() throws(LoxError) -> [Stmt] {
    var statements: [Stmt] = []
    while !check(.rightBrace), !isAtEnd {
      statements.append(try declaration())
    }
    try consume(type: .rightBrace) { [unowned self] in
      .expectBlock(peek(), $0)
    }
    return statements
  }

  private func expressionStatement() throws(LoxError) -> Stmt {
    let expr = try expression()
    try consume(type: .semicolon) { [unowned self] in
      .expectAfterExpression(peek(), $0)
    }
    return .expr(expr)
  }

  private func assignment() throws(LoxError) -> Expr {
    let expr = try equality()
    if match(.equal) {
      let equals = previous
      let value = try assignment()
      if case let .variable(t) = expr {
        return .assign(Expr.Assign(name: t, value: value))
      }
      throw .parser(.invalidAssignTarget(equals))
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
  private func consume(
    type: TokenType,
    expect: @escaping (TokenType) -> ParserError
  ) throws(LoxError) -> Token {
    if check(type) {
      return advance()
    }
    throw .parser(expect(type))
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
}
