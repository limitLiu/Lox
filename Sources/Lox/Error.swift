enum LoxError {
  case unexpectedCharacter(Int)
  case unterminatedString(Int)
}

typealias Result<T> = Swift.Result<T, LoxError>

extension LoxError: Swift.Error {}

extension LoxError: CustomStringConvertible {
  var description: String {
    switch self {
    case .unexpectedCharacter(let line):
      "[line \(line)] Error: Unexpected character."
    case .unterminatedString(let line):
      "[line \(line)] Error: Unterminated string."
    }
  }
}
