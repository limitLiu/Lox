public enum LoxError {
  case unexpectedCharacter(Int)
  case unterminatedString(Int)
}

public typealias Result<T> = Swift.Result<T, LoxError>

extension LoxError: Swift.Error {}

extension LoxError: CustomStringConvertible {
  public var description: String {
    switch self {
    case .unexpectedCharacter(let line):
      "[line \(line)] Error: Unexpected character."
    case .unterminatedString(let line):
      "[line \(line)] Error: Unterminated string."
    }
  }
}
