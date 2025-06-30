# GYMBLE - Gym Management System

## Quick Start Guide

### Prerequisites
- Node.js (v14 or higher)
- Python 3.11 or higher
- MongoDB (running locally)

### Running the Frontend

1. Navigate to the frontend directory:
   ```
   cd frontend
   ```

2. Install dependencies (including react-app-rewired):
   ```
   npm install
   npm install --save-dev react-app-rewired
   ```

3. Start the frontend application:
   ```
   npm start
   ```
   The application will open in your browser at http://localhost:3000

### Running the Backend

1. Navigate to the backend directory:
   ```
   cd backend
   ```

2. Install Python dependencies:
   ```
   pip install -r requirements.txt
   ```

3. Start the backend server:
   ```
   uvicorn server:app --host 0.0.0.0 --port 8000
   ```

### Environment Setup

Both frontend and backend require environment files:

- For frontend: Create a `.env` file in the `frontend` directory with:
  ```
  REACT_APP_BACKEND_URL=http://localhost:8000
  ```

- For backend: Create a `.env` file in the `backend` directory with:
  ```
  MONGO_URL=mongodb://localhost:27017/
  DB_NAME=GYMBLE
  JWT_SECRET_KEY=your_secret_key_for_jwt
  ```

## Optional: Sample Data

To initialize the database with sample data:
```
cd backend
python create_sample_data.py
```