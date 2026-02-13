# SpendWise – Personal Finance Tracker

## 📱 Overview
SpendWise is a modern Flutter-based personal finance management application designed to help users track expenses, set budgets, and visualize spending patterns.

## 🚀 Features
- Add, edit, and delete expenses
- Monthly budget tracking
- Spending analytics (Pie Chart & Bar Chart)
- Weekly spending breakdown
- Dark mode support
- Clean MVVM architecture

## 🏗 Architecture
The app follows a layered MVVM architecture:

- UI Layer (Flutter Widgets)
- Controller Layer (State Management)
- Data Layer (Local Storage)

## 🗃 Database Schema

### Expense
- id (Primary Key)
- title
- amount
- category
- date

### Category
- id (Primary Key)
- name
- icon
- color

## 🛠 Technologies Used
- Flutter
- Dart
- Android Studio
- Local Storage
- Git & GitHub

## 👨‍💻 Authors
Poe Eint Hmew (100002753)

## 🔗 GitHub Repository
https://github.com/poehmew/spendwise

## 📦 How to Run

1. repository:
 https://github.com/poehmew/spendwise.git

2. Navigate into project:
   cd spendwise

3. Get dependencies:
   flutter pub get

4. Run app:
   flutter run

5.Run web:
 flutter run -d chrome
