# ABIS2 - Enterprise Resource Planning System

ABIS2 is a comprehensive Flutter-based ERP (Enterprise Resource Planning) application designed to manage various aspects of business operations including billing, inventory management, logistics, finance, HR, and reporting.

## Overview

ABIS2 is a cross-platform application built with Flutter that provides an integrated solution for business management. The application is organized into several modules, each handling specific business functions.

## Features

### Authentication
- Secure login system
- User authentication with token-based access

### Billing Module
- Customer management (add, edit, search)
- Order processing
- Payment handling
- Invoice generation and printing
- Vehicle management

### Stock/Inventory Management
- Indent management
- Stock receiving
  - Regular receiving
  - Franchise sale returns
  - Consignment returns
  - GST transfer in
- Stock dispatch
  - Transfer out
  - Consignment issue
  - Group company sale
- Conversions
  - Live to dress
  - Dress to special
  - Egg crack
  - Special dress to special dress
  - Live stock adjust
  - RM to RM
- Wastage tracking
- Stocktake
- Bin transfer
- Production planning
  - Production plan
  - Demand for PP
- Production operations
  - Packaging
  - Merging
  - De-kitting

### Logistics
- Trip management
- Trip planning
- Delivery tracking
- Expense management
- Day end operations
- Odometer reset

### Finance
- Bank transfers
- Head office transfers
- Inter-branch transfers
- Opening receivables
- Payment processing
- Receipts management
  - From HO customer
  - From Silak customer
  - From other branches
  - Miscellaneous collections

### HR
- Attendance tracking
  - Day end attendance
  - Opening attendance
- Leave management

### Utilities
- Batch label management
- Bill of Materials (BOM)
- Carting charges
- Data synchronization
- Day end operations
- HO customer management
- Item management
- Sets management

### Reports
- Day rate reports
- Stock reports
- Ledger reports
- Opening balance reports
- Day reports

## Technical Details

### Built With
- [Flutter](https://flutter.dev/) - UI framework
- [Dart](https://dart.dev/) - Programming language
- [HTTP](https://pub.dev/packages/http) - API communication
- [Provider](https://pub.dev/packages/provider) - State management
- [Intl](https://pub.dev/packages/intl) - Internationalization and formatting
- [Flutter Blue Plus](https://pub.dev/packages/flutter_blue_plus) - Bluetooth connectivity
- [Blue Thermal Printer](https://pub.dev/packages/blue_thermal_printer) - Thermal printer integration
- [ESC/POS Utils](https://pub.dev/packages/esc_pos_utils) - Printer utilities
- [Connectivity Plus](https://pub.dev/packages/connectivity_plus) - Network connectivity

### API Integration
The application integrates with various backend APIs for data management:
- Customer management APIs
- Inventory APIs
- Transaction APIs
- Business day APIs
- And many more

## Getting Started

### Prerequisites
- Flutter SDK (^3.6.0)
- Dart SDK (^3.6.0)
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/abis2.git
```

2. Navigate to the project directory
```bash
cd abis2
```

3. Install dependencies
```bash
flutter pub get
```

4. Run the application
```bash
flutter run
```

## Project Structure

The project follows a modular structure with separate directories for each module:

```
lib/
├── api_handling/      # API integration
├── Billing/           # Billing module
├── Finance/           # Finance module
├── HR/                # Human Resources module
├── login_handling/    # Authentication
├── Logistics/         # Logistics module
├── Reports/           # Reporting module
├── Stock/             # Inventory management
│   ├── conversion/    # Stock conversion
│   ├── dispatch/      # Stock dispatch
│   ├── production/    # Production
│   ├── receiving/     # Stock receiving
├── Utils/             # Utilities
└── main.dart          # Application entry point
```


## Contact

For any inquiries, please contact [thakremahima1@gmail.com]
