public enum Value: Sendable {
  case string(String)
  case number(Double)
  case boolean(Bool)
  case callable(AnyCallable)
  case `nil`
}

extension Value: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case let (.number(l), .number(r)): l == r
    case let (.string(l), .string(r)): l == r
    case let (.boolean(l), .boolean(r)): l == r
    case (.nil, .nil): true
    default: false
    }
  }
}

extension Value: CustomStringConvertible {
  public var description: String {
    switch self {
    case .string(let s): s
    case .number(let n): n.description
    case .boolean(let b): b.description
    case .callable(let v): v.description
    case .nil: "nil"
    }
  }
}
