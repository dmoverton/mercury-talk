:- module sudoku.

:- interface.

:- import_module io.

:- pred main(io::di, io::uo) is cc_multi.


:- implementation.

:- import_module int, list, map, pair, solutions, string.

main(!IO) :-
  Problem = map.from_assoc_list([
    {1, 1} - 4, {2, 1} - 1,             {4, 1} - 3,                                     {8, 1} - 6, {9, 1} - 5,
                                        {4, 2} - 2,                                     {8, 2} - 4,
                                                    {5, 3} - 5, {6, 3} - 4, {7, 3} - 8, {8, 3} - 1,
                {2, 4} - 5,                                     {6, 4} - 2,
    {1, 5} - 6, {2, 5} - 4,                                                             {8, 5} - 7, {9, 5} - 2,
                                        {4, 6} - 6,                                     {8, 6} - 5,
                {2, 7} - 8, {3, 7} - 4, {4, 7} - 7, {5, 7} - 1,
                {2, 8} - 6,                                     {6, 8} - 3,
    {1, 9} - 5, {2, 9} - 7,                                     {6, 9} - 6,             {8, 9} - 8, {9, 9} - 1
  ]),
  io.write_string("Problem:\n", !IO),
  print_solution(Problem, !IO),
  io.nl(!IO),
  ( if sudoku(Problem, Solution) then
    io.write_string("Solution:\n", !IO),
    print_solution(Solution, !IO)
  else
    io.write_string("No solution found!\n", !IO)
  ).

:- func digits = list(int).
digits = [1, 2, 3, 4, 5, 6, 7, 8, 9].

:- type square == list(int). % Could use a bitmap for improved efficiency

:- func init_square = square.
init_square = digits.

:- type coord == {int, int}.

:- type board == map(coord, square).

:- type problem == map(coord, int).
:- type solution == map(coord, int).

:- func init_board = board.

:- type constraint == pred(board, board).
:- inst constraint == (pred(in, out) is semidet).

init_board =
  list.foldl(func(X, B0) =
     list.foldl(func(Y, B1) = map.set(B1, {X, Y}, init_square), digits, B0),
   digits,
   map.init).

% Set square equal to given value
:- pred set_square(coord::in, int::in, board::in, board::out) is semidet.

set_square(Coord, Value, !B) :-
  map.search(!.B, Coord, Square0),
  member(Value, Square0),
  Square = [Value],
  map.set(Coord, Square, !B),
  list.foldl(unset_square(Value), constrained_coords(Coord), !B).

% Set square not equal to given value
:- pred unset_square(int::in, coord::in, board::in, board::out) is semidet.

unset_square(Value, Coord, !B) :-
  map.search(!.B, Coord, Square0),
  ( if list.delete_first(Square0, Value, Square) then
    (
      Square = [Value1],
      set_square(Coord, Value1, !B)
    ;
      Square = [_, _ | _],
      map.set(Coord, Square, !B)
    )
  else
    true
  ).

:- func constrained_coords(coord) = list(coord).

constrained_coords(Coord) =
  solutions(constrained_coord(Coord)).

:- pred constrained_coord(coord::in, coord::out) is nondet.

constrained_coord(Coord0, Coord) :-
  ( same_row(Coord0, Coord)
  ; same_column(Coord0, Coord)
  ; same_box(Coord0, Coord)
  ).

:- pred same_row(coord::in, coord::out) is nondet.
:- pred same_column(coord::in, coord::out) is nondet.
:- pred same_box(coord::in, coord::out) is nondet.

same_row({X0, Y}, {X, Y}) :-
  member(X, digits),
  X \= X0.

same_column({X, Y0}, {X, Y}) :-
  member(Y, digits),
  Y \= Y0.

same_box(Coord0@{X0, Y0}, Coord@{X, Y}) :-
  member(X, digits),
  (X - 1) / 3 = (X0 - 1) / 3,
  member(Y, digits),
  (Y - 1) / 3 = (Y0 - 1) / 3,
  Coord \= Coord0.


:- pred solve(board::in, solution::out) is nondet.

solve(!.Board, Solution) :-
  Coords = map.keys(!.Board),
  foldl(label, Coords, !Board),
  map.map_values_only(list.head, !.Board, Solution).

:- pred label(coord::in, board::in, board::out) is nondet.

label(Coord, !B) :-
  map.search(!.B, Coord, Square),
  member(Value, Square),
  set_square(Coord, Value, !B).

:- pred sudoku(problem::in, solution::out) is nondet.

sudoku(Problem, Solution) :-
  Board0 = init_board,
  map.foldl(set_square, Problem, Board0, Board1),
  solve(Board1, Solution).

:- pred print_solution(solution::in, io::di, io::uo) is det.

print_solution(Solution, !IO) :-
  list.foldl(print_row(Solution), digits, !IO).

:- pred print_row(solution::in, int::in, io::di, io::uo) is det.

print_row(Solution, Y, !IO) :-
  list.foldl(print_square(Solution, Y), digits, !IO),
  io.nl(!IO).

:- pred print_square(solution::in, int::in, int::in, io::di, io::uo) is det.

print_square(Solution, Y, X, !IO) :-
  ( if Value = map.search(Solution, {X, Y}) then
    io.format("%d ", [i(Value)], !IO)
  else
    io.write_string("_ ", !IO)
  ).

