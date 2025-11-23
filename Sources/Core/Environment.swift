import struct Synchronization.Mutex

final class Environment: Sendable {
  private struct State {
    var values: [String: Value?] = [:]
  }

  private let enclosing: Environment?
  private let state = Mutex(State())

  private var values: [String: Value?] {
    get { state.withLock { $0.values } }
    set { state.withLock { $0.values = newValue } }
  }

  init(enclosing: Environment? = .none) {
    self.enclosing = enclosing
  }

  func define(_ name: String, forValue value: Value?) {
    values[name] = value
  }

  func get(at distance: Int, name: String) throws(LoxError) -> Value? {
    if let value = ancestor(distance).values[name] {
      return value
    } else {
      fatalError("Failed to get var name in local.")
    }
  }

  private func ancestor(_ distance: Int) -> Environment {
    var environment = self
    for _ in 0 ..< distance {
      if let enclosing = environment.enclosing {
        environment = enclosing
      } else {
        fatalError("Failed to get enclosing in distance range.")
      }
    }
    return environment
  }

  func get(_ name: Token) throws(LoxError) -> Value? {
    if let value = values[name.lexeme] {
      return value
    }
    if let enclosing {
      return try enclosing.get(name)
    }
    throw .environment(.undefinedVariable(name.lexeme))
  }

  func assign(at distance: Int, name: Token, value: Value?) {
    ancestor(distance).values[name.lexeme] = value
  }

  func assign(_ name: Token, forValue value: Value?) throws(LoxError) {
    if values.keys.contains(name.lexeme) {
      values[name.lexeme] = value
      return
    }
    if let enclosing {
      try enclosing.assign(name, forValue: value)
      return
    }
    throw .environment(.undefinedVariable(name.lexeme))
  }
}
