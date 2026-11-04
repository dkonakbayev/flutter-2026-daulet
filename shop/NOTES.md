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


## Level 2 — A model with no widgets

Created a separate Cart class extending ChangeNotifier.

The model contains:
- Private list of books
- Unmodifiable items getter
- Count getter
- Total getter
- add(), remove() and clear() methods
- Duplicate prevention

The model does not depend on UI widgets.


## Level 3 — Provider

Added provider package.

Used ChangeNotifierProvider above MaterialApp
to make Cart available throughout the application.

Removed cart parameters from widget constructors.

Used:
- context.watch<Cart>() for listening to changes
- context.read<Cart>() for actions
- Consumer<Cart> for rebuilding the cart list


### Incorrect watch usage

Tested context.watch<Cart>() inside onPressed.

Result: Provider throws an error because watch
cannot be used to subscribe from an event callback.

Error message:
"Another exception was thrown: Tried to listen to a value exposed with provider, from outside of the widget tree."


### Incorrect read usage

Tested context.read<Cart>() in CartBadge.build.

Result: The badge remained at 0 after adding books
because read does not subscribe to changes.

Restored context.watch<Cart>().


## Where Does It Live?

In this section, I explain where different types of data should be stored in the application and why.

### 1. Cart — Provided State (Provider)

The shopping cart is used on different screens. For example, the BooksScreen adds books to the cart, and the CartScreen shows the books and their total price.

Because both screens need the same cart data, I use Provider to share it across the application.

The Cart class extends ChangeNotifier. When the cart changes, it calls `notifyListeners()`. This tells the widgets that use the cart to update their UI.

**In simple words:** The cart is shared between different screens, so I use Provider.

### 2. Search Text — Ephemeral State (Local State)

Search text is only needed on the search screen. For example, when a user types a book name, the search screen uses this text to find matching books.

Other screens do not need this information. Therefore, it does not need to be shared with the whole application.

**In simple words:** Search text is used only on one screen, so local state is enough.

### 3. Expanded Total — Ephemeral State (Local State)

Expanded Total means whether the total price section is open or closed.

This information is only needed by the widget that displays the total price. Other screens do not need to know if this section is expanded or collapsed.

Therefore, this state can stay inside that widget.

**In simple words:** This setting affects only one widget, so it should stay local.

### 4. Theme Mode — Lifted State

Theme Mode controls whether the application uses a light or dark theme.

This setting affects the whole application, not just one screen. Therefore, it should be stored in a common parent widget, such as Shell.

Child screens can then use the same theme.

**In simple words:** The theme is needed by the whole application, so its state should be lifted to a common parent widget.

### Conclusion

Different types of state should be stored in different places. Local state is useful for one screen or widget. Lifted state is useful when several child widgets need the same information. Provider is useful when different parts of the application need access to shared data, such as the shopping cart.