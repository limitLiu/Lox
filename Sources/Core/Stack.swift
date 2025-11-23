public struct Stack<E: Sendable>: Sendable {
  private var inner: [E] = []

  mutating func push(_ element: E) {
    inner.append(element)
  }

  @discardableResult
  mutating func pop() -> E? {
    inner.popLast()
  }

  public var peek: E? {
    inner.last
  }

  public var isEmpty: Bool { inner.isEmpty }

  public var count: Int { inner.count }

  public func toArray() -> [E] { inner.map { $0 } }
}
