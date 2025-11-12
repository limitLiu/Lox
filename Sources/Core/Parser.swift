public class Parser {
  private let tokens: [Token]
  private var current: Int = 0

  public init(_ tokens: [Token]) {
    self.tokens = tokens
  }

  public func parse() -> Result<Expr> {
    do {
      return .success(try expression())
    } catch {
      synchronize()
      return .failure(error)
    }
  }
}

extension Parser {
  private func expression() throws(LoxError) -> Expr {
    try equality()
  }

  private func equality() throws(LoxError) -> Expr {
    var expr = try comparison()
    while match(.bangEqual, .equalEqual) {
      let op = previous
      let right = try comparison()
      expr = .binary(left: expr, op: op, right: right)
    }
    return expr
  }

  private func comparison() throws(LoxError) -> Expr {
    var expr = try term()
    while match(.greater, .greaterEqual, .less, .lessEqual) {
      let op = previous
      let right = try term()
      expr = .binary(left: expr, op: op, right: right)
    }
    return expr
  }

  private func term() throws(LoxError) -> Expr {
    var expr = try factor()
    while match(.minus, .plus) {
      let op = previous
      let right = try factor()
      expr = .binary(left: expr, op: op, right: right)
    }
    return expr
  }

  private func factor() throws(LoxError) -> Expr {
    var expr = try unary()
    while match(.slash, .star) {
      let op = previous
      let right = try unary()
      expr = .binary(left: expr, op: op, right: right)
    }
    return expr
  }

  private func unary() throws(LoxError) -> Expr {
    while match(.minus, .plus) {
      let op = previous
      let right = try unary()
      return .unary(op: op, right: right)
    }
    return try primary()
  }

  private func primary() throws(LoxError) -> Expr {
    switch advance().type {
    case .false: return .literal(.false)
    case .true: return .literal(.true)
    case .nil: return .literal(.nil)
    case .number(let n): return .literal(.number(n))
    case .str(let s): return .literal(.string(s))
    case .leftParen:
      let output = try expression()
      try consume(type: .rightParen)
      return Expr.grouping(output)
    default: throw .expectExpression(peek())
    }
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
      peek().type == type
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
  private func consume(type: TokenType) throws(LoxError) -> Token {
    if check(type) {
      return advance()
    }
    throw .expectExpressionAnd(peek(), type)
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
