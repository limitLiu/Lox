import ArgumentParser
import Core

@main
struct Lox: ParsableCommand {
  @Argument(help: "The path of the Lox script file.")
  var script: String?

  static let interpreter = Interpreter()

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
    do {
      let scanner = Scanner(src)
      let tokens = try scanner.scanTokens()
      let parser = Parser(tokens)
      let stmts = try parser.parse()
      let resolver = Resolver(Lox.interpreter)
      try resolver.resolve(stmts: stmts)
      Lox.interpreter.interpret(statements: stmts)
    } catch {
      print(error.localizedDescription)
    }
  }
}
