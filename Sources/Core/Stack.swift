public struct Stack<E: Sendable>: Sendable {
  private var inner: [E] = []

  mutating func push(_ element: E) {
    inner.append(element)
  }

  @discardableResult
  mutating func pop() -> E? {
    inner.popLast()
  }

  public var top: E? {
    get { inner.last }

    set {
      guard let newValue, !inner.isEmpty else { return }
      inner[inner.count - 1] = newValue
    }
  }

  public var isEmpty: Bool { inner.isEmpty }

  public var count: Int { inner.count }

  public func toArray() -> [E] { inner }
}

extension Stack {
  subscript(_ index: Int) -> E {
    inner[index]
  }
}
