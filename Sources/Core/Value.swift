public enum Value: Sendable {
  case string(String)
  case number(Double)
  case boolean(Bool)
  case callable(AnyCallable)
  case instance(LoxInstance)
  case `nil`
}

extension Value: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case let (.number(l), .number(r)): l == r
    case let (.string(l), .string(r)): l == r
    case let (.boolean(l), .boolean(r)): l == r
    case let (.instance(l), .instance(r)): l === r
    case (.nil, .nil): true
    default: false
    }
  }
}

extension Value: CustomStringConvertible {
  public var description: String {
    switch self {
    case let .string(s): s
    case let .number(n): n.description
    case let .boolean(b): b.description
    case let .callable(v): v.description
    case let .instance(i): i.description
    case .nil: "nil"
    }
  }
}
