# TensorFlow Lite GPU support
-keep class org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.lite.**

# The missing class from error
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory$Options { *; }

# Keep ML Kit
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# JNI / native
-keep class **.native** { *; }
