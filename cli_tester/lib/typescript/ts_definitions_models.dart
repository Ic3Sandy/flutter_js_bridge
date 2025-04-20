/// Model class for TypeScript parameter definition
class TSParameterDefinition {
  /// Name of the parameter
  final String name;
  
  /// TypeScript type of the parameter
  final String type;
  
  /// Whether the parameter is required
  final bool required;
  
  /// Description of the parameter
  final String? description;

  /// Creates a new TypeScript parameter definition
  const TSParameterDefinition({
    required this.name,
    required this.type,
    required this.required,
    this.description,
  });

  /// Converts the parameter definition to a TypeScript parameter declaration
  String toTypeScriptString() {
    final requiredMarker = required ? '' : '?';
    return '$name$requiredMarker: $type';
  }

  /// Creates a parameter definition from a JSON map
  factory TSParameterDefinition.fromJson(Map<String, dynamic> json) {
    return TSParameterDefinition(
      name: json['name'] as String,
      type: json['type'] as String,
      required: json['required'] as bool? ?? true,
      description: json['description'] as String?,
    );
  }

  /// Converts the parameter definition to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'required': required,
      if (description != null) 'description': description,
    };
  }
}

/// Model class for TypeScript property definition
class TSPropertyDefinition {
  /// Name of the property
  final String name;
  
  /// TypeScript type of the property
  final String type;
  
  /// Whether the property is required
  final bool required;
  
  /// Description of the property
  final String? description;

  /// Creates a new TypeScript property definition
  const TSPropertyDefinition({
    required this.name,
    required this.type,
    required this.required,
    this.description,
  });

  /// Converts the property definition to a TypeScript property declaration
  String toTypeScriptString() {
    final requiredMarker = required ? '' : '?';
    return '$name$requiredMarker: $type;';
  }

  /// Creates a property definition from a JSON map
  factory TSPropertyDefinition.fromJson(Map<String, dynamic> json) {
    return TSPropertyDefinition(
      name: json['name'] as String,
      type: json['type'] as String,
      required: json['required'] as bool? ?? true,
      description: json['description'] as String?,
    );
  }

  /// Converts the property definition to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'required': required,
      if (description != null) 'description': description,
    };
  }
}

/// Model class for TypeScript interface definition
class TSInterfaceDefinition {
  /// Name of the interface
  final String name;
  
  /// Properties of the interface
  final List<TSPropertyDefinition> properties;
  
  /// Description of the interface
  final String? description;

  /// Creates a new TypeScript interface definition
  const TSInterfaceDefinition({
    required this.name,
    required this.properties,
    this.description,
  });

  /// Creates an interface definition from a JSON map
  factory TSInterfaceDefinition.fromJson(Map<String, dynamic> json) {
    return TSInterfaceDefinition(
      name: json['name'] as String,
      properties: (json['properties'] as List)
          .map((prop) => TSPropertyDefinition.fromJson(prop as Map<String, dynamic>))
          .toList(),
      description: json['description'] as String?,
    );
  }

  /// Converts the interface definition to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'properties': properties.map((p) => p.toJson()).toList(),
      if (description != null) 'description': description,
    };
  }
}

/// Model class for TypeScript action definition
class TSActionDefinition {
  /// Name of the action
  final String name;
  
  /// Parameters of the action
  final List<TSParameterDefinition> parameters;
  
  /// Return type of the action
  final String returnType;
  
  /// Description of the action
  final String? description;

  /// Creates a new TypeScript action definition
  const TSActionDefinition({
    required this.name,
    required this.parameters,
    required this.returnType,
    this.description,
  });

  /// Creates an action definition from a JSON map
  factory TSActionDefinition.fromJson(Map<String, dynamic> json) {
    return TSActionDefinition(
      name: json['name'] as String,
      parameters: (json['parameters'] as List?)
              ?.map((param) => TSParameterDefinition.fromJson(param as Map<String, dynamic>))
              .toList() ??
          [],
      returnType: json['returnType'] as String,
      description: json['description'] as String?,
    );
  }

  /// Converts the action definition to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'parameters': parameters.map((p) => p.toJson()).toList(),
      'returnType': returnType,
      if (description != null) 'description': description,
    };
  }
}
