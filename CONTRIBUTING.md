# Contributing to Words625

Thank you for your interest in contributing to Words625! This open-source language learning app aims to make learning Indian languages accessible and enjoyable. We appreciate your enthusiasm and welcome contributions that align with our mission. Please read and follow these guidelines to ensure a smooth collaboration.

## Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [Ways to Contribute](#ways-to-contribute)
3. [Setting Up the Project](#setting-up-the-project)
4. [Contribution Guidelines](#contribution-guidelines)
5. [Commit Messages](#commit-messages)
6. [Pull Request Process](#pull-request-process)
7. [Feature Requests and Bug Reports](#feature-requests-and-bug-reports)
8. [Contact](#contact)

---

## Code of Conduct

Our project is dedicated to fostering a welcoming and inclusive environment. By participating, you agree to uphold our [Code of Conduct](./CODE_OF_CONDUCT.md). We expect all contributors to treat each other with respect and kindness.

## Ways to Contribute

1. **Reporting Bugs**: Help us improve by identifying issues or reporting bugs.
2. **Suggesting Features**: Propose new features or improvements to the app.
3. **Improving Documentation**: Contribute to better documentation for setup, usage, or the codebase.
4. **Writing Tests**: Ensure stability and accuracy of the code by adding tests.
5. **Coding**: Work on open issues or submit ideas for features.

## Setting Up the Project

### Prerequisites

1. Install Flutter: [Flutter Installation Guide](https://flutter.dev/docs/get-started/install)
2. Firebase account and access to a Firebase project: [Firebase Setup Guide](https://firebase.google.com/docs/flutter/setup)

### Clone the Repository

```bash
git clone https://github.com/rshrc/Words625.git
cd words625
```

### Install Dependencies

Run the following command to install necessary dependencies:

```bash
flutter pub get
```

### Connect Firebase

1. Set up Firebase for Android and iOS platforms as per the [Firebase documentation](https://firebase.google.com/docs/flutter/setup).
2. Add the `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS) files to the respective directories.

### Run the App

```bash
flutter run
```

You should now see Words625 running on your device or emulator.

## Contribution Guidelines

### Coding Standards

- Follow Flutter best practices and use Dart's recommended style.
- Write clear, modular code with proper comments.
- Adhere to Firebase integration standards for data storage, retrieval, and security.
- Write unit tests wherever possible, particularly for key features.

### Linting and Formatting

We use the `flutter_lints` package for consistent code styling. Before committing your code, please format it by running:

```bash
flutter format .
```

### Documentation

Update any relevant documentation in the `docs/` folder and ensure that new features or changes are well-documented.

## Commit Messages

Releases are generated automatically from commits merged into `main`, so use
[Conventional Commits](https://www.conventionalcommits.org/):

- `fix: correct scoring calculation` creates a patch release (`0.1.0` → `0.1.1`).
- `feat: add a Kannada lesson` creates a minor release (`0.1.0` → `0.2.0`).
- `feat!: replace the course format` creates a major release (`0.1.0` → `1.0.0`).
- A `BREAKING CHANGE:` footer also creates a major release.
- Other prefixes such as `docs:`, `test:`, and `chore:` do not create a release.

Scopes are optional; for example, `fix(lessons): handle empty choices`.

## Pull Request Process

1. Fork the repository and create a new branch with a descriptive name:
   ```bash
   git checkout -b feature/your-feature-name
   ```
2. Make your changes and commit them, ensuring to follow the guidelines.
3. Push your branch to your forked repository.
4. Create a pull request (PR) to the main repository. Include a detailed description of your changes.

### PR Review Process

- One or more team members will review your PR.
- Please be responsive to feedback and make necessary changes promptly.
- If your PR addresses an existing issue, link it in your PR description.

## Feature Requests and Bug Reports

1. **Feature Requests**: Check if the feature is already requested in the [Issues](https://github.com/yourusername/words625/issues) section. If not, open a new issue describing the feature and why it’s valuable.
2. **Bug Reports**: Provide a detailed description of the bug, steps to reproduce it, and any relevant error messages or screenshots.

## Contact

For major contributions or discussions, reach out to the maintainers at [your-email@example.com].

---

We’re excited to have you contribute to Words625 and help make language learning more accessible! Thank you for your interest and support.

---

By following these guidelines, you’ll help us maintain the quality and reliability of Words625 for all users. Let’s make learning languages more engaging together!

---
