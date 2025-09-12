# Cases List Screen - Firestore Integration

## Overview
The cases list screen has been updated to fetch data from the Firestore "cases" collection instead of using sample data.

## Files Created/Updated

### 1. `cases_list_screen.dart`
- **Type**: StatefulWidget with manual refresh
- **Features**: 
  - Manual refresh button in app bar
  - Pull-to-refresh functionality
  - Loading states and error handling
  - Uses `CaseService.getAllCases()` for data fetching

### 2. `cases_list_stream_screen.dart`
- **Type**: StatelessWidget with StreamBuilder
- **Features**:
  - Real-time updates from Firestore
  - Automatic refresh when data changes
  - Uses `CaseService.getCasesStream()` for real-time data

### 3. `case_service.dart`
- **Purpose**: Centralized service for all Firestore operations
- **Methods Available**:
  - `getAllCases()` - Fetch all cases
  - `getCasesStream()` - Real-time stream of cases
  - `getCaseById(id)` - Fetch single case
  - `addCase(case)` - Add new case
  - `updateCase(id, case)` - Update existing case
  - `deleteCase(id)` - Delete case
  - `completeCase(id)` - Mark case as completed
  - `getActiveCases()` - Get cases without doneDate
  - `getCompletedCases()` - Get cases with doneDate
  - `getCasesByClient(name)` - Search by client name
  - `searchCasesByTitle(term)` - Search by title

## Firestore Collection Structure

The app expects cases to be stored in a Firestore collection named `"cases"` with the following structure:

```json
{
  "title": "Case Title",
  "previousPostings": [
    {
      "title": "Posting Title",
      "date": "2024-01-15T10:00:00Z",
      "staff": "Staff Name",
      "court": "Court Name"
    }
  ],
  "nextPosting": {
    "title": "Next Posting Title",
    "date": "2024-01-20T10:00:00Z",
    "staff": "Staff Name",
    "court": "Court Name"
  },
  "clientName": "Client Name",
  "clientNumber": "+1234567890",
  "tasks": [
    {
      "title": "Task Title",
      "staff": "Staff Name",
      "dueDate": "2024-01-18T10:00:00Z",
      "doneDate": "2024-01-17T10:00:00Z"
    }
  ],
  "doneDate": "2024-01-25T10:00:00Z",
  "createdAt": "2024-01-10T10:00:00Z",
  "updatedAt": "2024-01-25T10:00:00Z"
}
```

## Usage

### Option 1: Manual Refresh (Recommended for most use cases)
```dart
// In main_home_screen.dart, use:
const CasesListScreen()
```

### Option 2: Real-time Updates (For collaborative environments)
```dart
// In main_home_screen.dart, use:
const CasesListStreamScreen()
```

## Features

### Active Cases Segment
- Shows cases with `doneDate: null`
- Sorted by `nextPosting.date`:
  - Today's items first (orange indicator)
  - Future items next (green indicator)
  - Overdue items (red indicator)
  - Cases with no future postings at the end

### Completed Cases Segment
- Shows cases with `doneDate: not null`
- Sorted by `doneDate` (most recent first)

### UI Features
- Color-coded date indicators
- Pull-to-refresh functionality
- Loading states
- Error handling with retry option
- Empty state messages
- Case count headers

## Error Handling

The implementation includes comprehensive error handling:
- Network connectivity issues
- Firestore permission errors
- Data parsing errors
- Empty collection states

## Performance Considerations

- Uses Firestore indexing for efficient queries
- Implements proper loading states
- Handles large datasets with pagination-ready structure
- Optimized sorting algorithms for UI responsiveness
