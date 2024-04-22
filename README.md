# What is Expensee?

Expensee is a full stack cross-platform mobile application designed to simplify financial management for individuals and small groups. Built using Flutter and Dart, and backed by Supabase, Expensee offers a robust solution for tracking expenses and managing budgets with ease. Whether you're looking to handle personal finances or collaborate on group budgets, Expensee provides all the tools you need, including role-based access control for team collaboration.

## Key Features
- **Individual and Group Budget Management:** Create, modify, and track budgets individually or as a group.
- **Receipt Management:** Upload and download receipts, with support for bulk operations.
- **Group Email**: Send custom mass emails to all group members, or just admin/owner.
- **Advanced Filtering:** Search through expenses by date, category, or user.
- **Secure Authentication:** Supports email/password, passwordless and Google OAuth2 logins.
- **Permission System**: In group boards, users can be Owner (only one), Admin or Shareholder with permissions based on role.
    - Owner has access to all features.
    - Admin has access to most features, with a few restrictions
    - Shareholder can only create, modify and delete their own expenses, but they can view other expenses.

# Getting Started

To run this app, the Flutter development environment must be set up first:

- An IDE that supports Flutter must be downloaded (VS Code is recommended).
- If you are on Windows, Android Studio must be installed, as well as an Android Emulator to run the app on. Visual Studio Build Tools is also required.
- If you are on MacOS, XCode must be installed and configured to enable emulation on iPhone devices. Android Studio can still be used to emulate on Android devices.
- Flutter SDK must be installed, a guide on this can be found here: https://docs.flutter.dev/get-started/install.
    - A guide for all of the above is shown to you on the flutter install page.
- When Flutter is installed, it is recommended to run "flutter doctor" in your command terminal to fix any issues in the background.
- After all this is done, while in the project directory run "flutter pub get" to install project dependencies.

# Vulkan

**IMPORTANT** - You must enable Vulkan on your Android emulator to support operations in the browser, such as logging in with Google. This also improves performance. Vulkan is a low-overhead, cross-platform API for high-performance 3D graphics. I found this works better if you are running the emulator from the command terminal. The command "emulator -avd <emulator-name-goes-here> -feature -Vulkan" in the directory where your emulator is stored does this. Alternatively, you can edit your emulator settings to make this permanent, but this never worked for me.

# Notes on Operating Systems
This was developed on Windows and as a result all testing was done on Android emulators. Due to this the receipt upload/download functionality may not work on iOS due to permission errors. On Android, these have to get added to the Android Manifest file. On iOS, this gets done in the info.plist file. However, due to not being able to test whether adding the ability to ask for permissions worked (I don't own a MacBook) on iOS I left this part. 

# Development Methodology
This was developed using a weekly Agile approach. Clear goals were set in Jira and deadlines adjusted according to what was priority at the time. A lot of research went into the overall architecture of this project prior to developing it. Particularily, I enlisted in courses on Flutter/Dart by Nick Manning, a project manager at Google, which aided significantly in the architecture design for this application. These courses can be found on [www.seenickcode.com](https://seenickcode.com/).

# Testing
Testing was mostly done as the project was developed, utilising Flutter's Hot Reload / Hot Restart functionality to test different pieces of code and make sure it works as expected before continuing on to the next feature. Manual system testing was carried out against the defined user requirements to make sure they were met. This area could be further improved with a CI/CD pipeline and automated integration testing and unit testing.

# Future Enhancements
- UI improvements to enhance user experience
- Export to CSV / Import from CSV
- Expense data visualisation - pie charts, bar charts etc
- Comment section for expenses
- Option to view all group members
- CI/CD pipeline

# Technologies Used
- Dart/Flutter for frontend + client functionality
- Supabase for backend, PostgreSQL database, database functions, edge functions and Row Level Security
- TypeScript for Email edge function
- Resend for the Email Service
- Jira for tracking progress
- Provider library for state management
- Logger with a pretty printer for future maintainability

# Architecture

**Higher Level Architecture Diagram**
![architecture-diagram](https://github.com/jkumz/expensee/assets/48411021/d317ce74-f837-4008-8c34-8cacbfcc0034)

**Models UML Diagram**
![models_uml](https://github.com/jkumz/expensee/assets/48411021/526caf5f-e7c3-4294-b6fe-7c3fb9962def)

**Providers UML Diagram**
![providers_uml](https://github.com/jkumz/expensee/assets/48411021/1e6cd092-35cb-440a-8529-fc447fa95503)

**Forms UML Diagram**
![forms_uml](https://github.com/jkumz/expensee/assets/48411021/ecd8576a-acd8-453e-bcdc-6d8d7ec2fa7b)

**Repository UML Diagram**
![repositories_uml](https://github.com/jkumz/expensee/assets/48411021/8782279b-9b57-4eb6-a44e-ce34dbee8b27)

**Service Layer UML Diagram**

![service_uml](https://github.com/jkumz/expensee/assets/48411021/a50ca4ca-fb94-4e88-9b72-cf6af7604172)


**Screens UML Diagram**
![screens_uml](https://github.com/jkumz/expensee/assets/48411021/928b1d70-7ef1-4ddb-8965-9296d36573e5)

**Simplified User Flow Diagram**
![user-flow-diagram](https://github.com/jkumz/expensee/assets/48411021/1ef4a296-8c06-4cc5-ac9a-fd6a96b92f95)


# Lessons Learned
- **Data Processing** - Data must be processed into a suitable format to be used with certain APIs and to be stored in the database or pulled from the database for use.
- **Importance of Initial Planning:** Extensive research and planning at the project's onset helped in understanding the necessary technologies and architecture, which streamlined the development process.
- **Agile Flexibility:** Using Agile methodology allowed for flexible response to challenges and changes, underscoring the importance of adaptability in project management.
- **Testing Strategy:** Early integration of a structured testing strategy would have accelerated troubleshooting and quality assurance, highlighting areas for improvement in future projects.
- **Over engineering** - Some features have no need to be super complex, time spent on these complexities is time gone from the overall goal of the project.

# Glossary
- RBAC: Role Based Access Control, in a nutshell it's what powers the permissions system.
- Provider: A state management mechanism in Dart/Flutter.
- Vulkan: a low-overhead, cross-platform API for high-performance 3D graphics. Like OpenGL ES (GLES), Vulkan provides tools for creating high-quality, real-time graphics in apps. Advantages of using Vulkan include reductions in CPU overhead and support for the SPIR-V Binary Intermediate language.
- OAuth2 - A standard designed to allow a website or application to access resources hosted by other web apps on behalf of a user.
- Supabase - An open-source Firebase alternative, providing a Postgres database with Row Level Security, simplified authentication, RESTful API using PostgREST, and Row Level Security.
- Row Level Security - A set of policies on each database table defining whether the user sending SQL queries to the database is authorised to make those queries. Restricts access on server side.
