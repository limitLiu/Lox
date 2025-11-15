final class Environment {
  private var values: [String: Value?] = [:]
  private let enclosing: Environment?

  init(enclosing: Environment? = .none) {
    self.enclosing = enclosing
  }

  func define(_ name: String, forValue value: Value?) {
    values[name] = value
  }

  func get(_ name: Token) throws(LoxError) -> Value? {
    if let value = values[name.lexeme] {
      return value
    }
    if enclosing != nil {
      return try enclosing?.get(name)
    }
    throw .environment(.undefinedVariable(name.lexeme))
  }

  func assign(_ name: Token, forValue value: Value?) throws(LoxError) {
    if values.keys.contains(name.lexeme) {
      values[name.lexeme] = value
      return
    }
    if enclosing != nil {
      try enclosing?.assign(name, forValue: value)
      return
    }
    throw .environment(.undefinedVariable(name.lexeme))
  }
}
