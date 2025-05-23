# campus_picks

A new Flutter project.

## Profiling and micro-optimisations

When checking performance issues, run the application in profile mode and open
the DevTools web view:

```bash
flutter run --profile -d chrome
```

Capture a screenshot of the timeline before and after applying any
optimisation. The example optimisation in this commit batches inserts of
recommended bets, reducing database overhead. Document the captured screenshots
in your performance report.
