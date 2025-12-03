import struct Synchronization.Mutex

public final class LoxClass: Sendable {
  init(_ name: String) {
    self.name = name
  }

  let name: String
}

extension LoxClass: Callable {
  public typealias T = Value

  public var arity: Int { 0 }

  public func call(interpreter: Interpreter, arguments: [Value]) throws -> T {
    let instance = LoxInstance(self)
    return .instance(instance)
  }

  public var description: String { name }
}

public final class LoxInstance: Sendable {
  private let klass: LoxClass

  private struct State {
    var fields: [String: Value] = [:]
  }

  private let state = Mutex(State())

  var fields: [String: Value] {
    get { state.withLock { $0.fields } }
    set { state.withLock { $0.fields = newValue } }
  }

  init(_ klass: LoxClass) {
    self.klass = klass
  }

  func get(_ name: Token) throws(LoxError) -> Value {
    if let value = fields[name.lexeme] {
      return value
    }
    throw .interpreter(.undefinedProperty(name))
  }

  func set(_ name: Token, value: Value) {
    fields[name.lexeme] = value
  }
}

extension LoxInstance: CustomStringConvertible {
  public var description: String { "\(klass.name) instance" }
}
