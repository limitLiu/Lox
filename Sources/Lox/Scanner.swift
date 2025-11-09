class Scanner {
  private let src: String
  private var tokens: [Token] = []

  private var start = 0
  private var current = 0
  private var line = 1

  private static let Keywords: [String: TokenType] = [
    "and": .and,
    "class": .class,
    "else": .else,
    "false": .false,
    "for": .for,
    "fun": .func,
    "if": .if,
    "nil": .nil,
    "or": .or,
    "print": .print,
    "return": .return,
    "super": .super,
    "this": .this,
    "true": .true,
    "var": .var,
    "while": .while,
  ]

  init(_ src: String) { self.src = src }
}

// MARK: - Private Methods

extension Scanner {
  private var isAtEnd: Bool {
    current >= src.count
  }

  @discardableResult
  private func advance() -> Character {
    let character = src[current]
    current += 1
    return character
  }

  private func addToken(_ type: TokenType) {
    let text = src[start ..< current].description
    tokens.append(Token(type: type, lexeme: text, line: line))
  }

  private func match(_ expected: Character) -> Bool {
    if isAtEnd { return false }
    if src[current] != expected { return false }
    current += 1
    return true
  }

  private func peek() -> Character {
    if isAtEnd { return "\0" }
    return src[current]
  }

  private func string() -> Result<()> {
    while peek() != "\"" && !isAtEnd {
      if peek() == "\n" { line += 1 }
      advance()
    }
    if isAtEnd {
      return .failure(LoxError.unterminatedString(line))
    }
    advance()
    let value = src[start + 1 ..< current - 1]
    addToken(.str(String(value)))
    return .success(())
  }

  private func isDigit(_ c: Character) -> Bool {
    c >= "0" && c <= "9"
  }

  private func isAlpha(_ c: Character) -> Bool {
    (c >= "a" && c <= "z") || (c >= "A" && c <= "Z") || c == "_"
  }

  private func identifier() {
    while isAlphaNumeric(peek()) { advance() }
    let text = src[start ..< current].description
    addToken(Self.Keywords[text] ?? .ident(text))
  }

  private func isAlphaNumeric(_ c: Character) -> Bool {
    isAlpha(c) || isDigit(c)
  }

  private func peekNext() -> Character {
    src[at: current + 1] ?? "\0"
  }

  private func number() {
    while isDigit(peek()) { advance() }
    if peek() == "." && isDigit(peekNext()) {
      advance()
      while isDigit(peek()) { advance() }
    }
    addToken(.number(Double(src[start ..< current])!))
  }
}

// MARK: Public Methods

extension Scanner {
  func scanTokens() -> Result<[Token]> {
    while !isAtEnd {
      start = current
      switch scanToken() {
      case .success:
        break
      case .failure(let e): return .failure(e)
      }
    }
    tokens.append(Token(type: .eof, lexeme: "", line: line))
    return .success(tokens)
  }

  func scanToken() -> Result<()> {
    let c = advance()
    switch c {
    case "(": addToken(.leftParen)
    case ")": addToken(.rightParen)
    case "{": addToken(.leftBrace)
    case "}": addToken(.rightBrace)
    case ",": addToken(.comma)
    case ".": addToken(.dot)
    case "-": addToken(.minus)
    case "+": addToken(.plus)
    case ";": addToken(.semicolon)
    case "*": addToken(.star)
    case "!": addToken(match("=") ? .bangEqual : .bang)
    case "=": addToken(match("=") ? .equalEqual : .equal)
    case "<": addToken(match("=") ? .lessEqual : .less)
    case ">": addToken(match("=") ? .greaterEqual : .greater)
    case "\"": return string()
    case "o":
      if peek() == "r" {
        addToken(.or)
      }
    case "/":
      if match("/") {
        while peek() != "\n" && !isAtEnd { advance() }
      } else {
        addToken(.slash)
      }
    case "\n": line += 1
    case " ", "\r", "\t": break
    default:
      if isDigit(c) {
        number()
      } else if isAlpha(c) {
        identifier()
      } else {
        return .failure(LoxError.unexpectedCharacter(line))
      }
    }
    return .success(())
  }
}
