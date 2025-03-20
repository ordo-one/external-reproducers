# task-cancellation

The program reproduces an issue where the `onCancel` callback of `withTaskCancellationHandler` is called more than once.
The issue is more easily reproducible in a release build.
