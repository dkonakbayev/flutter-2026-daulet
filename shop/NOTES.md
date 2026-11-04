# Notes

## Level 1: Lift it up

- Constructors touched to add `total` to the badge: 2
  (`BooksScreen` and `CartBadge`). Plus 1 call site in `Shell`
  (`_ShellState`), which passes `total` into `BooksScreen`.
- Files touched: 3 (`lib/main.dart`, `lib/books_screen.dart`,
  `lib/cart_badge.dart`). `BooksScreen` does not use `total` itself,
  it only passes it down to `CartBadge`.
- Lines printed in the console for one tap on Add: 7
  (1 x `BooksScreen build` + 6 x `row ...`, one per book).
  One tap rebuilt the whole screen and every row, because `setState`
  in `Shell` marks everything under it dirty.