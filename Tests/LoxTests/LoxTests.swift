import Testing

@testable import Core
@testable import Lox

@Test func testToken() async throws {
  let input: String = """
    var five = 5;
    var ten = 10;
    fun add(x, y) {
      return x + y;
    }

    var result = add(five, ten);
    !-/*5;
    5 < 10 > 5;
    if (5 < 10) {
      return true;
    } else {
      return false;
    }
    10 == 10;
    10 != 9;
    "foobar"
    "foo bar"
    """

  let tokens = try Scanner(input).scanTokens().get()
  let expectedTokens: [Token] = [
    // line 1
    Token(type: .var, lexeme: "var", line: 1),
    Token(type: .ident("five"), lexeme: "five", line: 1),
    Token(type: .equal, lexeme: "=", line: 1),
    Token(type: .number(5), lexeme: "5", line: 1),
    Token(type: .semicolon, lexeme: ";", line: 1),
    // line 2
    Token(type: .var, lexeme: "var", line: 2),
    Token(type: .ident("ten"), lexeme: "ten", line: 2),
    Token(type: .equal, lexeme: "=", line: 2),
    Token(type: .number(10), lexeme: "10", line: 2),
    Token(type: .semicolon, lexeme: ";", line: 2),
    // line 3
    Token(type: .func, lexeme: "fun", line: 3),
    Token(type: .ident("add"), lexeme: "add", line: 3),
    Token(type: .leftParen, lexeme: "(", line: 3),
    Token(type: .ident("x"), lexeme: "x", line: 3),
    Token(type: .comma, lexeme: ",", line: 3),
    Token(type: .ident("y"), lexeme: "y", line: 3),
    Token(type: .rightParen, lexeme: ")", line: 3),
    Token(type: .leftBrace, lexeme: "{", line: 3),
    // line 4
    Token(type: .return, lexeme: "return", line: 4),
    Token(type: .ident("x"), lexeme: "x", line: 4),
    Token(type: .plus, lexeme: "+", line: 4),
    Token(type: .ident("y"), lexeme: "y", line: 4),
    Token(type: .semicolon, lexeme: ";", line: 4),
    // line 5
    Token(type: .rightBrace, lexeme: "}", line: 5),
    // line 7
    Token(type: .var, lexeme: "var", line: 7),
    Token(type: .ident("result"), lexeme: "result", line: 7),
    Token(type: .equal, lexeme: "=", line: 7),
    Token(type: .ident("add"), lexeme: "add", line: 7),
    Token(type: .leftParen, lexeme: "(", line: 7),
    Token(type: .ident("five"), lexeme: "five", line: 7),
    Token(type: .comma, lexeme: ",", line: 7),
    Token(type: .ident("ten"), lexeme: "ten", line: 7),
    Token(type: .rightParen, lexeme: ")", line: 7),
    Token(type: .semicolon, lexeme: ";", line: 7),
    // line 8
    Token(type: .bang, lexeme: "!", line: 8),
    Token(type: .minus, lexeme: "-", line: 8),
    Token(type: .slash, lexeme: "/", line: 8),
    Token(type: .star, lexeme: "*", line: 8),
    Token(type: .number(5), lexeme: "5", line: 8),
    Token(type: .semicolon, lexeme: ";", line: 8),
    // line 9
    Token(type: .number(5), lexeme: "5", line: 9),
    Token(type: .less, lexeme: "<", line: 9),
    Token(type: .number(10), lexeme: "10", line: 9),
    Token(type: .greater, lexeme: ">", line: 9),
    Token(type: .number(5), lexeme: "5", line: 9),
    Token(type: .semicolon, lexeme: ";", line: 9),
    // line 10
    Token(type: .if, lexeme: "if", line: 10),
    Token(type: .leftParen, lexeme: "(", line: 10),
    Token(type: .number(5), lexeme: "5", line: 10),
    Token(type: .less, lexeme: "<", line: 10),
    Token(type: .number(10), lexeme: "10", line: 10),
    Token(type: .rightParen, lexeme: ")", line: 10),
    Token(type: .leftBrace, lexeme: "{", line: 10),
    // line 11
    Token(type: .return, lexeme: "return", line: 11),
    Token(type: .true, lexeme: "true", line: 11),
    Token(type: .semicolon, lexeme: ";", line: 11),
    // line 12
    Token(type: .rightBrace, lexeme: "}", line: 12),
    Token(type: .else, lexeme: "else", line: 12),
    Token(type: .leftBrace, lexeme: "{", line: 12),
    // line 13
    Token(type: .return, lexeme: "return", line: 13),
    Token(type: .false, lexeme: "false", line: 13),
    Token(type: .semicolon, lexeme: ";", line: 13),
    // line 14
    Token(type: .rightBrace, lexeme: "}", line: 14),
    // line 15
    Token(type: .number(10), lexeme: "10", line: 15),
    Token(type: .equalEqual, lexeme: "==", line: 15),
    Token(type: .number(10), lexeme: "10", line: 15),
    Token(type: .semicolon, lexeme: ";", line: 15),
    // line 16
    Token(type: .number(10), lexeme: "10", line: 16),
    Token(type: .bangEqual, lexeme: "!=", line: 16),
    Token(type: .number(9), lexeme: "9", line: 16),
    Token(type: .semicolon, lexeme: ";", line: 16),
    // line 17
    Token(type: .str("foobar"), lexeme: "\"foobar\"", line: 17),
    // line 18
    Token(type: .str("foo bar"), lexeme: "\"foo bar\"", line: 18),
    Token(type: .eof, lexeme: "", line: 18),
  ]

  #expect(tokens == expectedTokens)
}

@Test func testASTPrinter() async throws {
  let actual = ASTPrinter().print(
    expr: .binary(
      left: .unary(
        op: Token(
          type: .minus,
          lexeme: "-",
          line: 1
        ),
        right: .literal(.number(123))
      ),
      op:
        Token(type: .star, lexeme: "*", line: 1),
      right: .grouping(.literal(.number(45.67)))
    )
  )
  let expected = "(* (- 123.0) (group 45.67))"
  #expect(actual == expected)
}
