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
  ( if solve_sudoku(Problem, Solution) then
    io.write_string("Solution:\n", !IO),
    print_solution(Solution, !IO)
  else
    io.write_string("No solution found!\n", !IO)
  ).

% -------------------------------------------------------------------------------- %

:- func digits = list(int).
digits = [1, 2, 3, 4, 5, 6, 7, 8, 9].

% List of possible values a cell can take
:- type cell == list(int). % Could use a bitmap for improved efficiency

:- func init_cell = cell.
init_cell = digits.

:- type coord == {int, int}.

% Constraint store
:- type grid == map(coord, cell).

:- type problem == map(coord, int).
:- type solution == map(coord, int).

:- func init_grid = grid.

init_grid =
  map.from_assoc_list(solutions(init_pair)).

:- pred init_pair(pair(coord, cell)::out) is nondet.

init_pair({X, Y} - init_cell) :-
  member(X, digits),
  member(Y, digits).

% -------------------------------------------------------------------------------- %

% Set cell equal to given value
:- pred set_cell_value(coord::in, int::in, grid::in, grid::out) is semidet.

set_cell_value(Coord, Value, !Grid) :-
  map.search(!.Grid, Coord, Cell0),
  member(Value, Cell0),
  Cell = [Value],
  map.set(Coord, Cell, !Grid),
  list.foldl(exclude_value(Value), constrained_coords(Coord), !Grid).

% Set cell not equal to given value
:- pred exclude_value(int::in, coord::in, grid::in, grid::out) is semidet.

exclude_value(Value, Coord, !Grid) :-
  map.search(!.Grid, Coord, Cell0),
  ( if list.delete_first(Cell0, Value, Cell) then
    (
      Cell = [Value1],
      set_cell_value(Coord, Value1, !Grid)
    ;
      Cell = [_, _ | _],
      map.set(Coord, Cell, !Grid)
    )
  else
    true
  ).

% -------------------------------------------------------------------------------- %

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

% -------------------------------------------------------------------------------- %

:- pred solve_sudoku(problem::in, solution::out) is nondet.

solve_sudoku(Problem, Solution) :-
  % Set up constraints
  map.foldl(set_cell_value, Problem, init_grid, Grid),

  % Find solutions (a.k.a "labelling")
  solve(Grid, Solution).

:- pred solve(grid::in, solution::out) is nondet.

solve(!.Grid, Solution) :-
  Coords = map.keys(!.Grid),
  foldl(label, Coords, !Grid),
  map.map_values_only(list.head, !.Grid, Solution).

:- pred label(coord::in, grid::in, grid::out) is nondet.

label(Coord, !Grid) :-
  map.search(!.Grid, Coord, Cell),
  member(Value, Cell),
  set_cell_value(Coord, Value, !Grid).

% -------------------------------------------------------------------------------- %

:- pred print_solution(solution::in, io::di, io::uo) is det.

print_solution(Solution, !IO) :-
  list.foldl(print_row(Solution), digits, !IO).

:- pred print_row(solution::in, int::in, io::di, io::uo) is det.

print_row(Solution, Y, !IO) :-
  list.foldl(print_cell(Solution, Y), digits, !IO),
  io.nl(!IO).

:- pred print_cell(solution::in, int::in, int::in, io::di, io::uo) is det.

print_cell(Solution, Y, X, !IO) :-
  ( if map.search(Solution, {X, Y}, Value) then
    io.format("%d ", [i(Value)], !IO)
  else
    io.write_string("_ ", !IO)
  ).

