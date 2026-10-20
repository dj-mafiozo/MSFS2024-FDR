# Analysis precision and delta deadband

Floating-point numbers in AI context are rounded to at most three decimal places, recursively through objects and arrays: contact, weather, statistics, SDK, engines and FMC references. Trailing zeros are omitted and negative zero becomes zero. Integers/Int64 IDs are preserved without conversion through Double. Text, including raw FMC/MCDU, is unchanged. This affects analysis serialization, not original recordings.

Subsequent analysis samples use a ±0.0015 deadband in the parameter's own units. Comparison is made after rounding against the last emitted/reconstructed value, not the previous raw reading. Skipped changes can accumulate until they exceed the threshold. A 0.001 difference is omitted; 0.002 is emitted. A 1e-12 tolerance protects the comparison from Double arithmetic noise. This is not a moving average or a separate threshold per parameter.

Example: 1.00049 → 1.00051 → 1.0014 → 1.0021 yields baseline 1.000, two omissions, then 1.002. Null, booleans, strings, discrete integers, appearance/removal and engine availability remain meaningful changes. Nested deltas reconstruct the complete state; removed values are explicit. VerifyPrecision and VerifyContext cover rounding boundaries, drift accumulation, sign/zero, nested data, missing engines and reconstruction. No real model request is needed.
