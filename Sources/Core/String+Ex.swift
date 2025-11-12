nonisolated extension String {
  public subscript(at offset: Int) -> Element? {
    guard !isEmpty, let index = index(startIndex, offsetBy: offset, limitedBy: endIndex), index < endIndex else {
      return .none
    }
    return self[index]
  }

  public subscript(_ offset: Int) -> Element {
    return self[index(startIndex, offsetBy: offset)]
  }

  public subscript(at range: Range<Int>) -> Substring? {
    guard let start = index(startIndex, offsetBy: range.lowerBound, limitedBy: endIndex),
      let end = index(startIndex, offsetBy: range.upperBound, limitedBy: endIndex),
      start <= end
    else { return .none }
    return self[start ..< end]
  }

  public subscript(_ range: Range<Int>) -> Substring {
    let start = index(startIndex, offsetBy: range.lowerBound)
    let end = index(startIndex, offsetBy: range.upperBound)
    return self[start ..< end]
  }

  public subscript(at range: ClosedRange<Int>) -> Substring? {
    guard let start = index(startIndex, offsetBy: range.lowerBound, limitedBy: endIndex),
      let end = index(startIndex, offsetBy: range.upperBound, limitedBy: index(before: endIndex)),
      start <= end
    else { return .none }
    return self[start ... end]
  }

  public subscript(_ range: ClosedRange<Int>) -> Substring {
    let start = index(startIndex, offsetBy: range.lowerBound)
    let end = index(startIndex, offsetBy: range.upperBound)
    return self[start ... end]
  }
}
