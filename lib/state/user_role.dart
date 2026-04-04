enum UserRole {
  coach,
  trainee;

  String get labelHe => switch (this) {
        UserRole.coach => 'מאמן',
        UserRole.trainee => 'מתאמן',
      };
}
