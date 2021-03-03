/// We're keeping it simple by not having any fields inside the custom
/// Exceptions. If you'd like to convey more information about the error,
/// feel free to add a message field into the class in your projects.

class ServerException implements Exception {}

class CacheException implements Exception {}
