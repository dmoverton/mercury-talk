:- module hello.
:- interface.
:- import_module io.

:- pred main(io::di, io::uo) is det.

:- implementation.

:- import_module list, string.

main(IO0, IO) :-
  io.write_string("What is your name?\n", IO0, IO1),
  io.read_line_as_string(Result, IO1, IO2),
  (
    Result = ok(String),
    io.format("Hello %s, nice to meet you!\n", [s(strip(String))], IO2, IO)
  ;
    Result = eof,
    io.write_string("Ok, bye!\n", IO2, IO)
  ;
    Result = error(Err),
    io.write_string("Error: ", IO2, IO3),
    io.print(Err, IO3, IO)
  ).

:- pred main2(io::di, io::uo) is det.

main2(!IO) :-
  io.write_string("What is your name?\n", !IO),
  io.read_line_as_string(Result, !IO),
  (
    Result = ok(String),
    io.format("Hello %s, nice to meet you!\n", [s(strip(String))], !IO)
  ;
    Result = eof,
    io.write_string("Ok, bye!\n", !IO)
  ;
    Result = error(Err),
    io.write_string("Error: ", !IO),
    io.print(Err, !IO)
  ).
