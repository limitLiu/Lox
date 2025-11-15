import ArgumentParser
import Core

@main
struct Lox: ParsableCommand {
  @Argument(help: "The path of the Lox script file.")
  var script: String?

  nonisolated(unsafe) static let interpreter = Interpreter()

  mutating func run() throws {
    if let script {
      runFile(path: script)
    } else {
      runPrompt()
    }
  }
}

extension Lox {
  func runFile(path: String) {
    do {
      let content = try String(contentsOfFile: path, encoding: .utf8)
      execute(content)
    } catch {
      print(error.localizedDescription)
    }
  }

  func runPrompt() {
    while true {
      print("> ", terminator: "")
      guard let line = readLine(), !line.isEmpty else { break }
      execute(line)
    }
  }

  private func execute(_ src: String) {
    let scanner = Scanner(src)
    switch scanner.scanTokens() {
    case .success(let tokens):
      let parser = Parser(tokens)
      switch parser.parse() {
      case .success(let stmts):
        Lox.interpreter.interpret(statements: stmts)
      case .failure(let e):
        print(e.description)
      }
    case .failure(let error):
      print(error.description)
    }
  }
}
