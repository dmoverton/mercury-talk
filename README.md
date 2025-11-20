# The Mercury Programming Language

Slides and sample code from my [talk to the Melbourne Compose Group](https://luma.com/nqg5ckh3), 20th November 2025, on the [Mercury programming language](https://mercurylang.org/index.html).

## Files
- `talk.md`: [Marp](https://marp.app/) markdown for my talk slides
- `talk.pdf`: Rendered PDF of the above
- `hello.m`: sample Mercury program doing I/O
- `sudoku.m`: sample Mercury program for solving Sudoku

## Building

To build the HTML or PDF slides, [install `marp-cli`](https://github.com/marp-team/marp-cli?tab=readme-ov-file#install) then do

```sh
marp --html talk.md
```
or
```sh
marp --pdf talk.md
```
To build the sample programs, [download and install Mercury](https://mercurylang.org/download.html) then do

```sh
mmc --make hello
```
or
```sh
mmc --make sudoku
```
