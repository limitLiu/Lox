public protocol CustomComparable {
  static func =~ (lhs: Self, rhs: Self) -> Bool
}

infix operator =~ : ComparisonPrecedence
