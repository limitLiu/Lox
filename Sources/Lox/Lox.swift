import ArgumentParser

@main
struct Lox: ParsableCommand {
  @Argument(help: "The path of the Lox script file.")
  var script: String?

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
      let content = try String(contentsOfFile: path)
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
      tokens.forEach { print($0) }
    case .failure(let error):
      print(error.description)
    }
  }
}
