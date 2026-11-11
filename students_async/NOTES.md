LEVEL 1 — ACTUAL OBSERVATIONS

1. Event Loop:
   A and C appeared immediately.
   The Flutter application started without waiting.
   After two seconds, B and 6 students appeared.

2. API errors:
   The first request succeeded.
   The second request succeeded.
   The third request threw NoConnectionException.

3. sleep() experiment:
   sleep() blocked the main isolate for two seconds.
   The first Flutter frame was delayed.

4. Important:
   await pauses an asynchronous function.
   sleep() blocks the execution thread.

LEVEL 2 — MOUNTED EXPERIMENT

I temporarily removed the mounted checks.

After opening StudentsScreen and leaving it
before the API response arrived, Flutter reported:

setState() called after dispose()

The API response arrived after the widget
was disposed. The mounted check prevents
setState() from being called on a disposed widget.
LEVEL 2 — UI STATES

The StudentsScreen supports four UI states:

Loading — displayed while the API request is running.

Error — displayed when the API request fails, with a Retry button.

Empty — displayed when the API returns an empty list.

Data — displays the list of students.

The Retry button starts a new API request.

LEVEL 3 — FUTUREBUILDER

The Future is stored in a state field and initialized in initState().

The FutureBuilder handles:

Errors using snapshot.hasError.

Loading using connectionState.

Empty data using an empty list.

Successful data by displaying the students.

Changing the Switch does not start another API request because the Future is stored and reused.

Retry creates a new Future and starts another request.

LEVEL 4 — STREAMS

The countdown Stream emits values from 5 to 0, with approximately one second between values.

Version A uses StreamBuilder to listen to the stream and update the UI.

Version B uses listen() and StreamSubscription to update the UI manually.

The subscription is cancelled in dispose() to prevent unnecessary updates after the screen is closed.

LEVEL 5 — SAVING DATA

The Save button uses await to wait for the API operation.

The application handles StateError with try/catch.

The _saving flag disables the button while the save operation is running.

The error message is displayed when saving fails.

Navigator.pop() is called only after a successful save.

The mounted/context.mounted check prevents navigation or UI updates after the widget is disposed.

FINAL VERIFICATION

dart format . — successful.

flutter analyze — successful.

No analyzer errors were reported.